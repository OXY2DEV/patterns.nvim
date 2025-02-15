local utils = {};
local nodes = require("patterns.nodes");

--- Checks if a parser is available or not
---@param parser_name string
---@return boolean
utils.parser_installed = function (parser_name)
	local has_ts, parsers = pcall(require, "nvim-treesitter.parsers");

	if has_ts == false then
		--- `nvim-treesitter` not available.
		return false;
	elseif parsers.has_parser(parser_name) == true then
		--- Parser installed via `nvim-treesitter`.
		return true;
	elseif pcall(vim.treesitter.query.get, parser_name, "highlights") ~= nil then
		--- Parser installed manually.
		return true;
	end

	return false;
end

--- Get pattern range under cursor.
--- Returns nil on fail.
---@return nil | string
---@return nil | string[]
---@return nil | integer[]
utils.create_pattern_range = function ()
	---@type boolean, table
	local has_parser, parser = pcall(vim.treesitter.get_parser);

	if has_parser == true then
		---@type integer
		local buffer = vim.api.nvim_get_current_buf();
		---@type string
		local lang = parser:lang();
		---@type table
		local on_node = vim.treesitter.get_node({ ignore_injections = true });

		while on_node do
			---@type string
			local node_ty = on_node:type();

			---@type [ integer, integer ]
			local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win());
			---@type integer[]
			local range = { on_node:range() };

			---@type string
			local text = vim.treesitter.get_node_text(on_node, buffer);

			if text:match('^%"') then
				text = text:gsub('^%"+', "");
				range[2] = range[2] + 1;

				text = text:gsub('%"+$', "");
				range[4] = range[4] - 1;
			elseif text:match('^%/') then
				text = text:gsub('^%/', "");
				range[2] = range[2] + 1;

				text = text:gsub('/$', "");
				range[4] = range[4] - 1;
			end

			text = vim.split(text, "\n", { trimempty = true })

			if nodes.get_ft(lang, node_ty) then
				return nodes.get_ft(lang, node_ty), vim.islist(text) and text or { text }, range;
			end

			on_node = on_node:parent();
		end

		vim.api.nvim_echo({
			{ " 󰑑 patterns.nvim ", "DiagnosticVirtualTextInfo" },
			{ ": Couldn't find text node under cursor!", "Comment" }
		}, true, { verbose = false });
	else
		local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win());
		local line = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), cursor[1] - 1, cursor[1], false)[1]

		local before, after = string.sub(line, 0, cursor[2]), string.sub(line, cursor[2] + 1);
		local tB, tA = before:match("%S*$"), after:match("^%S*");

		if tB == "" and tA == "" then
			vim.api.nvim_echo({
				{ " 󰑑 patterns.nvim ", "DiagnosticVirtualTextInfo" },
				{ ": Couldn't find text under cursor!", "Comment" }
			}, true, { verbose = false });
		else
			return "LuaPatterns", { tB .. tA }, { cursor[1], cursor[2] - #tB, cursor[1], cursor[2] + #tA };
		end
	end
end

--- Get which quadrant to open the window on.
---
--- ```txt
---    top, left ↑ top, right
---            ← █ →
--- bottom, left ↓ bottom, right
--- ```
---@param w integer
---@param h integer
---@return [ "left" | "right" | "center", "top" | "bottom" | "center" ]
utils.get_quadrant = function (w, h)
	---|fS

	---@type integer
	local window = vim.api.nvim_get_current_win();
	---@type [ integer, integer ]
	local src_c  = vim.api.nvim_win_get_cursor(window);

	--- (Terminal) Screen position.
	---@class screen.pos
	---
	---@field row integer Screen row.
	---@field col integer First screen column.
	---@field endcol integer Last screen column.
	---
	---@field curscol integer Cursor screen column.
	local scr_p = vim.fn.screenpos(window, src_c[1], src_c[2]);

	---@type integer, integer Vim's width & height.
	local vW, vH = vim.o.columns, vim.o.lines - (vim.o.cmdheight or 0);
	---@type "left" | "right", "top" | "bottom"
	local x, y;

	if scr_p.curscol - w <= 0 then
		--- Not enough spaces on `left`.
		if scr_p.curscol + w >= vW then
			--- Not enough space on `right`.
			return { "center", "center" };
		else
			--- Enough spaces on `right`.
			x = "right";
		end
	else
		--- Enough space on `left`.
		x = "left";
	end

	if scr_p.row + h >= vH then
		--- Not enough spaces on `top`.
		if scr_p.row - h <= 0 then
			--- Not enough spaces on `bottom`.
			return { "center", "center" };
		else
			y = "top";
		end
	else
		y = "bottom";
	end

	return { x, y };

	---|fE
end

--- Clamps a value between a range
---@param val number
---@param min number
---@param max number
---@return number
utils.clamp = function (val, min, max)
	return math.min(math.max(val, min), max);
end

--- Checks if a highlight group exists or not
---@param hl string?
---@return string?
utils.set_hl = function (hl)
	if type(hl) ~= "string" then
		return;
	end

	if vim.fn.hlexists("Patterns" .. hl) == 1 then
		return "Patterns" .. hl;
	else
		return hl;
	end
end

utils.create_user_command_class = function (config)
	local class = {};

	class.config = config;

	function class.exec (self, params)
		local sub = params.fargs[1];

		local function exec_subcommand ()
			if config.sub_commands == nil then
				return false;
			elseif config.sub_commands[sub] == nil then
				return false;
			elseif config.sub_commands[sub].action == nil then
				return false;
			end

			return true;
		end

		if sub == nil and self.config.default and self.config.default.action then
			self.config.default.action(params);
		elseif exec_subcommand() == true then
			self.config.sub_commands[sub].action(params);
		end
	end

	function class.comp (self, arg_lead, cmdline, cursor_pos)
		---+${lua}

		local is_subcommand = function (text)
			local cmds = vim.tbl_keys(self.config.sub_commands or {});
			return vim.list_contains(cmds, text);
		end

		local matches_subcommand = function (text)
			if is_subcommand(text) then
				return false;
			end

			for key, _ in pairs(self.config.sub_commands or {}) do
				if key:match(text) then
					return true;
				end
			end

			return false;
		end

		local nargs = 0;
		local args  = {};

		local text = cmdline:sub(0, cursor_pos);

		for arg in text:gmatch("(%S+)") do
			nargs = nargs + 1;
			table.insert(args, arg);
		end

		table.remove(args, 1);
		nargs = nargs - 1;

		local item;

		if nargs == 0 or (nargs == 1 and matches_subcommand(args[1])) then
			item = self.config.default;
		elseif is_subcommand(args[1]) and self.config.sub_commands and self.config.sub_commands[args[1]] then
			item = self.config.sub_commands[args[1]];
		else
			return {};
		end

		if vim.islist(item.completion) then
			return item.completion --[[ @as string[] ]];
		elseif pcall(item.completion, arg_lead, cmdline, cursor_pos) then
			---@type string[]
			return item.completion(arg_lead, cmdline, cursor_pos);
		end
		---_
	end

	return class;
end

utils.win_findbuf = function (buffer)
	local wins = vim.fn.win_findbuf(buffer);

	if vim.list_contains(wins, vim.api.nvim_get_current_win()) then
		return vim.api.nvim_get_current_win();
	else
		return wins[1];
	end
end

utils.to_lines = function (text, max_width)
	max_width = max_width or 1;

	local _l = {};
	local width = 0;

	local function cut_str (str)
		local _c = {};
		local times = math.floor(vim.fn.strdisplaywidth(str) / max_width);

		for i = 1, times, 1 do
			table.insert(
				_c,
				vim.fn.strcharpart(str, (i - 1) * max_width, i * max_width)
			);
		end

		return _c;
	end

	local txt_lines = vim.split(text, "\n", { trimempty = true });

	for _, line in ipairs(txt_lines) do
		local _t = {};

		for part in string.gmatch(line, "%s*%S*") do
			local len = vim.fn.strdisplaywidth(part);

			if len >= max_width then
				local non_white = part:gsub("^%s*", "");
				local n_len = vim.fn.strdisplaywidth(non_white);

				if n_len <= max_width then
					table.insert(_l, non_white);
				else
					_t = vim.list_extend(
						_t,
						cut_str(non_white)
					);
				end

				width = 0;
			elseif (width + len) <= max_width then
				if #_t == 0 then
					table.insert(_t, part);
					width = len;
				else
					_t[#_t] = _t[#_t] .. part;
					width = width + len;
				end

			else
				table.insert(_t, part);
				width = len;
			end
		end

		_l = vim.list_extend(_l, _t);
	end

	return _l;
end

return utils;
