local hover = {};

local spec = require("patterns.spec");
local utils = require("patterns.utils");

---@type integer Autocmd group
hover.au = vim.api.nvim_create_augroup("patterns.hover", { clear = true });

---@type integer, integer Hover buffer & window.
hover.buf, hover.win = nil, nil;

--- `vim.lsp.buf.hover()` but for patterns.
hover.hover = function ()
	if hover.win and vim.api.nvim_win_is_valid(hover.win) then
		vim.api.nvim_set_current_win(hover.win);
		return;
	end

	local ft, lines, range = utils.create_pattern_range();

	if not ft or not lines or not range then
		return;
	end

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

		footer = user_config.title,
		footer_pos = user_config.title_pos,

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

	local content = require("patterns.parser").parse(hover.buf);
	vim.api.nvim_buf_set_lines(hover.buf, 0, -1, false, {});

	require("patterns.renderer").render(hover.buf, content);

	vim.bo[hover.buf].modifiable = false;

	---|fE

	---|fS "Fix hover window position"

	local quadrent = utils.get_quadrant(hover_config.width, math.min(
		hover_config.height,
		vim.api.nvim_buf_line_count(hover.buf)
	));

	local w, h = hover_config.width, math.min(vim.api.nvim_buf_line_count(hover.buf), hover_config.height);
	local row, col;

	if quadrent[1] == "center" then
		col = math.floor((vim.o.columns - w) / 2);
	elseif quadrent[1] == "left" then
		col = (w * -1) - 1;
	else
		col = 0;
	end

	if quadrent[2] == "center" then
		row = math.floor((vim.o.lines - h) / 2);
	elseif quadrent[2] == "top" then
		row = (h * -1) - 2;
	else
		row = 0;
	end

	user_config = spec.get({ "windows", "hover" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = math.floor(vim.o.lines * 0.5)
		},

		args = { quadrent[1], quadrent[2] }
	});

	vim.api.nvim_win_set_config(hover.win, {
		relative = "cursor",

		row = row,
		col = col,

		width = w,
		height = h,

		border = user_config.border
	});

	---|fE

	---|fE

	local function hover_close ()
		hover.au = vim.api.nvim_create_augroup("patterns.hover", { clear = true });
		pcall(vim.api.nvim_win_close, hover.win, true);
	end

	vim.api.nvim_buf_set_keymap(hover.buf, "n", "q", "", {
		callback = function ()
			hover_close()
		end
	});

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = hover.au,
		-- pattern = { tostring(src_win) },

		callback = function ()
			local win = vim.api.nvim_get_current_win();

			if win ~= hover.win then
				hover_close();
			end
		end
	})
end

return hover;
