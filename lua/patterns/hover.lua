local hover = {};

local spec = require("patterns.spec");
local utils = require("patterns.utils");

---@type integer Autocmd group
hover.au = vim.api.nvim_create_augroup("patterns.hover", { clear = true });

---@type integer, integer Hover buffer & window.
hover.buf, hover.win = nil, nil;

hover.actions = {
	close = function ()
		hover.au = vim.api.nvim_create_augroup("patterns.hover", { clear = true });
		pcall(vim.api.nvim_win_close, hover.win, true);
	end,

	edit = function ()
		hover.actions.close();
		require("patterns.explain").explain(unpack(hover.data or {}))
	end
};

--- `vim.lsp.buf.hover()` but for patterns.
hover.hover = function ()
	if hover.win and vim.api.nvim_win_is_valid(hover.win) then
		vim.api.nvim_set_current_win(hover.win);
		return;
	end

	local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win());
	local ft, lines, range = utils.create_pattern_range();
	local available_parsers = { "lua_patterns", "regex" };

	available_parsers = vim.tbl_filter(function (parser)
		return utils.parser_installed(parser);
	end, available_parsers);

	if not ft or not lines or not range then
		return;
	elseif #available_parsers == 0 then
		vim.api.nvim_echo({
			{ " 󰑑 patterns.nvim ", "DiagnosticVirtualTextInfo" },
			{ ": ", "Comment" },
			{ "Looks like you don't have the necessary parsers installed! See README.", "Comment" },
		}, true, {})
		return;
	elseif vim.list_contains(available_parsers, ft) == false then
		ft = available_parsers[1];
	end

	--- Export the data.
	hover.data = { ft, table.concat(lines, ""), range };

	---|fS "Preparation"

	---@type table User's window configuration.
	local user_config = spec.get({ "windows", "hover" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = math.floor(vim.o.lines * 0.5)
		},

		args = { "right", "bottom" }
	});

	---@type table Hover window config.
	local hover_config = {
		relative = "cursor",

		row = 1,
		col = 1,

		width = user_config.width or math.floor(vim.o.columns * 0.6),
		height = user_config.height or math.floor(vim.o.lines * 0.5),

		title = user_config.title,
		title_pos = user_config.title_pos,

		footer = user_config.footer,
		footer_pos = user_config.footer_pos,

		style = "minimal",
		border = user_config.border
	};

	--- Create hover buffer.
	if not hover.buf or vim.api.nvim_buf_is_valid(hover.buf) == false then
		hover.buf = vim.api.nvim_create_buf(false, true);
	end

	---|fS "Render preview"

	vim.bo[hover.buf].ft = ft;
	vim.bo[hover.buf].modifiable = true;

	vim.api.nvim_buf_set_lines(hover.buf, 0, -1, false, lines);

	if not hover.win or vim.api.nvim_win_is_valid(hover.win) == false then
		hover.win = vim.api.nvim_open_win(hover.buf, false, hover_config);
	else
		vim.api.nvim_win_set_config(hover.win, hover_config);
	end

	--- This is the relative cursor position inside
	--- the pattern.
	--- Used to get the correct current node.
	pcall(vim.api.nvim_win_set_cursor, hover.win,{
		cursor[1] - range[1],
		cursor[2] - range[2]
	});

	local content = require("patterns.parser").parse(hover.buf);
	vim.api.nvim_buf_set_lines(hover.buf, 0, -1, false, {});

	local _l = require("patterns.renderer").render(hover.buf, content);

	vim.bo[hover.buf].modifiable = false;

	---|fE

	---|fS "Fix hover window position"

	local quadrent = utils.get_quadrant(hover_config.width, math.min(
		hover_config.height,
		vim.api.nvim_buf_line_count(hover.buf)
	));

	local w, h = hover_config.width, math.min(vim.api.nvim_buf_line_count(hover.buf), hover_config.height);

	local relative = "cursor";
	local row, col;

	if quadrent[1] == "center" then
		relative = "editor";
		col = math.floor((vim.o.columns - w) / 2);
	elseif quadrent[1] == "left" then
		col = (w * -1) - 1;
	else
		col = 0;
	end

	if quadrent[2] == "center" then
		relative = "editor";
		row = math.floor((vim.o.lines - h) / 2);
	elseif quadrent[2] == "top" then
		row = (h * -1) - 2;
	else
		row = 1;
	end

	user_config = spec.get({ "windows", "hover" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = math.floor(vim.o.lines * 0.5)
		},

		args = { quadrent[1], quadrent[2] }
	});

	vim.api.nvim_win_set_config(hover.win, {
		relative = relative,

		row = row,
		col = col,

		width = w,
		height = h,

		title = user_config.title,
		title_pos = user_config.title_pos,

		footer = user_config.footer,
		footer_pos = user_config.footer_pos,

		border = user_config.border
	});

	--- Change the cursor position again so that
	--- the current node doesn't go outside of
	--- the visible window.
	pcall(vim.api.nvim_win_set_cursor, hover.win,{
		_l,
		0
	});

	---|fE

	---|fE

	local keymaps = spec.get({ "keymaps", "hover" }, { fallback = {} });

	for lhs, map in pairs(keymaps) do
		local callback = map.callback;

		if type(callback) == "string" then
			if hover.actions[callback] then
				callback = hover.actions[callback];
			else
				callback = nil;
			end
		end

		vim.api.nvim_buf_set_keymap(
			hover.buf,
			map.mode or "n",
			lhs,
			map.rhs or "",
			{
				desc = map.desc,
				callback = callback
			}
		);
	end

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = hover.au,

		callback = function ()
			local win = vim.api.nvim_get_current_win();

			if win ~= hover.win then
				hover.actions.close();
			end
		end
	})
end

return hover;
