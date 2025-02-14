local patterns = {};
local spec = require("patterns.spec");
local nodes = require("patterns.nodes");

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
local function get_quadrant (w, h)
	---+${lua}

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

	return { x, y }
	---_
end

--- Renders stuff to the preview buffer
patterns.render = function (src_buf, prev_buf)
	---@type { [string]: table[] } The parsed content.
	local content = require("patterns.parser").parse(src_buf);

	vim.api.nvim_buf_set_lines(prev_buf, 0, -1, false, {});
	return require("patterns.renderer").render(prev_buf, content);
end

patterns.viewer_close = function ()
	patterns.au = vim.api.nvim_create_augroup("patterns", { clear = true });

	pcall(vim.api.nvim_win_close, patterns.preview_win, true);
	pcall(vim.api.nvim_win_close, patterns.input_win, true);
end

patterns.input_buf = nil;
patterns.input_win = nil

patterns.hover_buf = nil;
patterns.hover_win = nil

patterns.hover_au = vim.api.nvim_create_augroup("patterns.hover", { clear = true });

patterns.__set_bufs = function ()
	if not patterns.input_buf or vim.api.nvim_buf_is_valid(patterns.input_buf) then
		patterns.input_buf = vim.api.nvim_create_buf(false, true);
	end

	if not patterns.hover_buf or vim.api.nvim_buf_is_valid(patterns.hover_buf) then
		patterns.hover_buf = vim.api.nvim_create_buf(false, true);
	end
end

patterns.hover = function (ft, text, cursor_pos)
	---|fS "Prepare buffers."

	patterns.__set_bufs();

	if patterns.hover_win and vim.api.nvim_win_is_valid(patterns.hover_win) then
		vim.api.nvim_set_current_win(patterns.hover_win);
		return;
	end

	---|fE

	local function closs_hover()
		pcall(vim.api.nvim_win_close, patterns.hover_win, true);
		patterns.hover_au = vim.api.nvim_create_augroup("patterns.hover", { clear = true });
	end

	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = patterns.hover_au,
		callback = function ()
			local win = vim.api.nvim_get_current_win();

			if win ~= patterns.hover_win then
				closs_hover();
			end
		end
	})

	---@type table Hover window config.
	local hover_spec = spec.get({ "windows", "hover" }, {
		fallback = {
			width = math.ceil(vim.o.columns * 0.4), height = math.ceil(vim.o.lines * 0.5),

			border = "rounded"
		}
	});

	---|fS "Initial render"

	patterns.hover_win = vim.api.nvim_open_win(patterns.hover_buf, false, {
		relative = "editor",

		row = 1, col = 1,
		width = hover_spec.width, height = hover_spec.height
	});

	vim.bo[patterns.hover_buf].ft = ft;
	vim.bo[patterns.hover_buf].modifiable = true;

	vim.api.nvim_buf_set_lines(patterns.hover_buf, 0, -1, false, text);
	pcall(vim.api.nvim_win_set_cursor, patterns.hover_win, cursor_pos);

	---@type integer Cursor line;
	local Y = patterns.render(patterns.hover_buf, patterns.hover_buf);

	---|fE

	---|fS "Position preview"

	local width, height = hover_spec.width, math.min(vim.api.nvim_buf_line_count(patterns.hover_buf), hover_spec.height);
	local quad = get_quadrant(width, height);
	local relative, row, col = "cursor", 0, 0;

	if quad[1] == "left" then
		col = (hover_spec.width * -1) - 1;
	elseif quad[1] == "right" then
		col = 0;
	else
		hover_spec.relative = "editor";
		col = math.ceil((vim.o.columns - width) / 2);
	end

	if quad[2] == "top" then
		row = (height * -1) - 2;
	elseif quad[2] == "bottom" then
		row = 1;
	else
		relative = "editor";
		row = math.ceil((vim.o.lines - height) / 2);
	end

	vim.api.nvim_win_set_config(patterns.hover_win, {
		style = "minimal",
		relative = relative,

		row = row,
		col = col,

		width = width,
		height = height,

		border = hover_spec.border
	});

	if Y then
		pcall(vim.api.nvim_win_set_cursor, patterns.hover_win, { Y, 0 });
	end

	---|fE
end

patterns.actions = {
	hover = function ()
		local has_parser, parser = pcall(vim.treesitter.get_parser);

		if has_parser == true then
			local buffer = vim.api.nvim_get_current_buf();
			local lang = parser:lang();
			local on_node = vim.treesitter.get_node({ ignore_injections = true });

			while on_node do
				local node_ty = on_node:type();

				local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win());
				local range = { on_node:range() };

				local text = vim.treesitter.get_node_text(on_node, buffer);

				if text:match('^%"') then
					text = text:gsub('^"', "");
					range[2] = range[2] + 1;

					text = text:gsub('"$', "");
					range[4] = range[4] - 1;
				elseif text:match('^%/') then
					text = text:gsub('^/', "");
					range[2] = range[2] + 1;

					text = text:gsub('/$', "");
					range[4] = range[4] - 1;
				end

				if nodes.get_ft(lang, node_ty) then
					--- This is a string.
					patterns.hover(nodes.get_ft(lang, node_ty), { text }, { 1, cursor[2] - range[2] });
					return;
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

			local before, after = string.sub(line, 0, cursor[1]), string.sub(line, cursor[1]);
			local tB, tA = before:match("%S*$"), after:match("^%S*");

			patterns.hover("LuaPatterns", { tB .. tA }, { 1, cursor[2] - #tB });
		end
	end
};

patterns.setup = function (user_config)
end

return patterns;
