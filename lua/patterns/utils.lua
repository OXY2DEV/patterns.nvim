local utils = {};

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

--- Escapes magic characters from a string
---@param input string
---@return string
utils.escape_string = function (input)
	input = input:gsub("%%", "%%%%");

	input = input:gsub("%(", "%%(");
	input = input:gsub("%)", "%%)");

	input = input:gsub("%.", "%%.");
	input = input:gsub("%+", "%%+");
	input = input:gsub("%-", "%%-");
	input = input:gsub("%*", "%%*");
	input = input:gsub("%?", "%%?");
	input = input:gsub("%^", "%%^");
	input = input:gsub("%$", "%%$");

	input = input:gsub("%[", "%%[");
	input = input:gsub("%]", "%%]");

	return input;
end

--- Clamps a value between a range
---@param val number
---@param min number
---@param max number
---@return number
utils.clamp = function (val, min, max)
	return math.min(math.max(val, min), max);
end

--- Linear interpolation between 2 values
---@param x number
---@param y number
---@param t number
---@return number
utils.lerp = function (x, y, t)
	return x + ((y - x) * t);
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

utils.virt_len = function (virt_texts)
	if not virt_texts then
		return 0;
	end

	local _l = 0;

	for _, text in ipairs(virt_texts) do
		_l = _l + vim.fn.strdisplaywidth(text[1]);
	end

	return _l;
end

utils.tostatic = function (tbl, opts)
	if not opts then opts = {}; end
	local _o = {};

	for k, v in pairs(tbl or {}) do
		---@diagnostic disable
		if
			pcall(v, unpack(opts.args or {}))
		then
			_o[k] = v(unpack(opts.args or {}));
		---@diagnostic enable
		elseif type(v) ~= "function" then
			_o[k] = v;
		end
	end

	return _o;
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

--- Gets a config from a list of config tables.
--- NOTE, {name} will be used to index the config.
---@param config table
---@param name string
---@param opts { default: boolean, def_fallback: any?, eval_args: any[], ignore_keys?: any[] }
---@return any
utils.match = function (config, name, opts)
	config = config or {};
	name = name or "";
	opts = opts or {};

	local spec = require("markview.spec");

	--- Default configuration
	local default = {};

	if opts.default ~= false then
		default = spec.get({ "default" }, vim.tbl_extend("keep", {
			source = config,
			fallback = opts.def_fallback
		}, opts));
	end

	local match = {};

	local sort_keys = function (values)
		local w_priority = {};
		local n_priority = {};

		for k, v in pairs(values or {}) do
			if type(v) == "table" and type(v.priority) == "number" then
				table.insert(w_priority, {
					key = k,
					priority = v.priority
				});
			elseif k ~= "default" and vim.list_contains(opts.ignore_keys or {}, k) == false then
				table.insert(n_priority, k);
			end
		end

		table.sort(w_priority, function (a, b)
			return a.priority > b.priority;
		end)

		local keys = {};

		for _, item in ipairs(w_priority) do
			table.insert(keys, item.key);
		end

		keys = vim.list_extend(n_priority, keys);

		return keys;
	end

	local function is_valid (value, pattern)
		local ignore = opts.ignore_keys or {};

		if vim.list_contains(ignore, pattern) then
			return false;
		elseif string.match(value, pattern) then
			return true;
		else
			return false;
		end
	end

	--- NOTE, We should sort the keys so that we
	--- don't get different results every time
	--- when multiple patterns can be matched.
	---
	---@type string[]
	local keys = sort_keys(config or {});

	for _, key in ipairs(keys) do
		if is_valid(name, key) == true then
			match = spec.get(
				{ key },
				vim.tbl_extend("force", opts, { source = config })
			);
			break
		end
	end

	return vim.tbl_deep_extend("force", default, match);
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
