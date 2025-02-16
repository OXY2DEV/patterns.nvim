local patterns = {};
local spec = require("patterns.spec");
local nodes = require("patterns.nodes");

local hover = require("patterns.hover");
local explain = require("patterns.explain");

--- Renders stuff to the preview buffer
patterns.render = function (src_buf, prev_buf)
	---@type { [string]: table[] } The parsed content.
	local content = require("patterns.parser").parse(src_buf);

	vim.bo[prev_buf].modifiable = true;

	vim.api.nvim_buf_set_lines(prev_buf, 0, -1, false, {});
	return require("patterns.renderer").render(prev_buf, content);
end

--- Renders stuff to the preview buffer
patterns.clear = function (prev_buf)
	vim.bo[prev_buf].modifiable = true;

	vim.api.nvim_buf_set_lines(prev_buf, 0, -1, false, {});
	return require("patterns.renderer").clear(prev_buf);
end

patterns.match = function ()
	if not patterns.input_buf or vim.api.nvim_buf_is_valid(patterns.input_buf) == false then
		return;
	elseif not patterns.preview_buf or vim.api.nvim_buf_is_valid(patterns.preview_buf) == false then
		return;
	elseif patterns.explain_mode ~= 2 then
		return;
	end

	vim.api.nvim_buf_clear_namespace(patterns.preview_buf, patterns.ns, 0, -1);

	local input = table.concat(vim.api.nvim_buf_get_lines(patterns.input_buf, 0, -1, false), "\n");

	if input == "" then
		return;
	end

	for l, line in ipairs(vim.api.nvim_buf_get_lines(patterns.preview_buf, 0, -1, false)) do
		if string.match(line, "^%s*$") then
			goto continue;
		end

		local can_match = pcall(string.match, line, input);
		local matches = {};

		local _line = line;
		local offset = 0;

		for match in line:gmatch(input) do
			local from, to = string.find(_line, match, 1, true );
			_line = _line:gsub(match, "", 1);

			vim.print(match)

			table.insert(matches, {
				match,
				{ from, to }
			});

			vim.api.nvim_buf_set_extmark(patterns.preview_buf, patterns.ns, l - 1, (from + offset) - 1, {
				invalidate = true, undo_restore = false,
				end_col = to + offset,

				hl_group = "DiagnosticOk"
			});

			offset = offset + #match;
		end

		vim.api.nvim_buf_set_extmark(patterns.preview_buf, patterns.ns, l - 1, 0, {
			invalidate = true, undo_restore = false,

			virt_text_pos = "right_align",
			virt_text = (can_match and #matches > 0) and {
				{ "󰄲 ", "DiagnosticOk" }
			} or {
				{ "󰄮 ", "DiagnosticError" }
			}
		});

	    ::continue::
	end
end

---@type integer Input buffer.
patterns.input_buf = nil;
---@type integer Input window.
patterns.input_win = nil

---@type integer Input buffer.
patterns.preview_buf = nil;
---@type integer Input window.
patterns.preview_win = nil

---@type
---| 1 Explain mode.
---| 2 Match mode.
patterns.explain_mode = 1;

patterns.__explain_lines = nil;
patterns.__explain_pos = nil;

patterns.ns = vim.api.nvim_create_namespace("patterns");

---@type integer Hover buffer.
patterns.hover_buf = nil;
---@type integer Hover window.
patterns.hover_win = nil

---@type integer Autocmd group for the hover window.
patterns.hover_au = vim.api.nvim_create_augroup("patterns.hover", { clear = true });

---@type integer Autocmd group for the explain window.
patterns.explain_au = vim.api.nvim_create_augroup("patterns.explain", { clear = true });

--- Sets up all the buffers.
patterns.__set_bufs = function ()
	if not patterns.input_buf or vim.api.nvim_buf_is_valid(patterns.input_buf) then
		patterns.input_buf = vim.api.nvim_create_buf(false, true);
	end

	if not patterns.preview_buf or vim.api.nvim_buf_is_valid(patterns.preview_buf) then
		patterns.preview_buf = vim.api.nvim_create_buf(false, true);
	end

	if not patterns.hover_buf or vim.api.nvim_buf_is_valid(patterns.hover_buf) then
		patterns.hover_buf = vim.api.nvim_create_buf(false, true);
	end
end

patterns.update_explain = function ()
	---|fS

	local input_config = spec.get({ "windows", "input" }, { fallback = {
		width = math.floor(vim.o.columns * 0.5), height = 1
	}});

	local preview_config = spec.get({ "windows", "preview" }, { fallback = {
		width = math.floor(vim.o.columns * 0.5), height = 15
	}});

	if not patterns.input_win or vim.api.nvim_win_is_valid(patterns.input_win) == false then
		patterns.input_win = vim.api.nvim_open_win(patterns.input_buf, true, vim.tbl_extend("force", input_config, {
			relative = "editor",

			row = math.floor((vim.o.lines - (input_config.height + preview_config.height + 4)) / 2),
			col = math.floor((vim.o.columns - preview_config.width) / 2),

			title_pos = "right",
			title = vim.bo[patterns.input_buf].ft == "LuaPatterns" and {
				{ " 󰽀 Lua patterns ", "PatternsPalette0" }
			} or {
				{ "  Regex ", "PatternsPalette0" }
			},

			border = "rounded",
			style = "minimal"
		}));
	else
		vim.api.nvim_win_set_config(patterns.input_win, {
			relative = "editor",

			row = math.floor((vim.o.lines - (input_config.height + preview_config.height + 4)) / 2),
			col = math.floor((vim.o.columns - preview_config.width) / 2),

			title_pos = "right",
			title = vim.bo[patterns.input_buf].ft == "LuaPatterns" and {
				{ " 󰽀 Lua patterns ", "PatternsPalette0" }
			} or {
				{ "  Regex ", "PatternsPalette0" }
			},

			border = "rounded",
			style = "minimal"
		});
	end

	if not patterns.preview_win or vim.api.nvim_win_is_valid(patterns.preview_win) == false then
		patterns.preview_win = vim.api.nvim_open_win(patterns.preview_buf, false, vim.tbl_extend("force", preview_config, {
			relative = "editor",

			row = math.floor((vim.o.lines - (input_config.height + preview_config.height + 4)) / 2) + 3,
			col = math.floor((vim.o.columns - preview_config.width) / 2),

			footer_pos = "right",
			footer = {
				{ " " },
				{ " 󰂖 Explain ", patterns.explain_mode == 1 and "PatternsPalette7" or "PatternsPalette0" },
				{ " " },
				{ " 󰄺 Match ", patterns.explain_mode == 2 and "PatternsPalette7" or "PatternsPalette0" },
				{ " " }
			},

			border = "rounded",
			style = "minimal"
		}));
	else
		vim.api.nvim_win_set_config(patterns.preview_win, {
			relative = "editor",

			row = math.floor((vim.o.lines - (input_config.height + preview_config.height + 4)) / 2) + 3,
			col = math.floor((vim.o.columns - preview_config.width) / 2),

			footer_pos = "right",
			footer = {
				{ " " },
				{ " 󰂖 Explain ", patterns.explain_mode == 1 and "PatternsPalette7" or "PatternsPalette0" },
				{ " " },
				{ " 󰄺 Match ", patterns.explain_mode == 2 and "PatternsPalette7" or "PatternsPalette0" },
				{ " " }
			},

			border = "rounded",
			style = "minimal"
		});
	end

	vim.wo[patterns.input_win].winhl = "FloatBorder:PatternsInputBorder";
	vim.wo[patterns.preview_win].winhl = "FloatBorder:PatternsPreviewBorder";

	---|fE
end

patterns.explain_close = function ()
	patterns.explain_au = vim.api.nvim_create_augroup("patterns.explain", { clear = true });

	if patterns.explain_mode == 2 then
		_, patterns.__explain_lines = pcall(vim.api.nvim_buf_get_lines, patterns.preview_buf, 0, -1, false);
		_, patterns.__explain_pos = pcall(vim.api.nvim_win_get_cursor, patterns.preview_win);
	end

	pcall(vim.api.nvim_win_close, patterns.input_win, true);
	pcall(vim.api.nvim_win_close, patterns.preview_win, true);

	patterns.input_win = nil;
	patterns.preview_win = nil;
end

patterns.actions = {
	hover = function ()
		---|fS

		hover.hover();

		---|fE
	end,

	explain = function (ft, text, range)
		if 1 < 2 then
			explain.explain(ft, text[1], range);
			return;
		end

		ft = ft or "LuaPatterns";
		text = text or "";

		patterns.__set_bufs();
		patterns.explain_mode = patterns.explain_mode or 1;

		vim.bo[patterns.input_buf].ft = ft;

		vim.api.nvim_buf_set_lines(patterns.input_buf, 0, -1, false, text);
		patterns.update_explain();

		if patterns.explain_mode == 1 then
			patterns.render(patterns.input_buf, patterns.preview_buf)
			vim.bo[patterns.preview_buf].modifiable = false;
		else
			patterns.match();
		end

		---|fS "Keymaps"

		vim.api.nvim_buf_set_keymap(patterns.input_buf, "n", "<tab>", "", {
			callback = function ()
				vim.api.nvim_set_current_win(patterns.preview_win);
			end
		});

		vim.api.nvim_buf_set_keymap(patterns.preview_buf, "n", "<tab>", "", {
			callback = function ()
				vim.api.nvim_set_current_win(patterns.input_win);
			end
		});

		vim.api.nvim_buf_set_keymap(patterns.preview_buf, "n", "M", "", {
			callback = function ()
				patterns.explain_mode = 2;
				patterns.clear(patterns.preview_buf);

				pcall(vim.api.nvim_buf_set_lines, patterns.preview_buf, 0, -1, false, patterns.__explain_lines);
				pcall(vim.api.nvim_win_set_cursor, patterns.preview_win, patterns.__explain_pos);

				vim.bo[patterns.preview_buf].modifiable = true;

				patterns.update_explain();
			end
		});

		vim.api.nvim_buf_set_keymap(patterns.preview_buf, "n", "E", "", {
			callback = function ()
				patterns.explain_mode = 1;

				_, patterns.__explain_lines = pcall(vim.api.nvim_buf_get_lines, patterns.preview_buf, 0, -1, false);
				_, patterns.__explain_pos = pcall(vim.api.nvim_win_get_cursor, patterns.preview_win);

				patterns.render(patterns.input_buf, patterns.preview_buf);
				vim.bo[patterns.preview_buf].modifiable = false;

				patterns.update_explain();
			end
		});

		---|fE

		vim.api.nvim_create_autocmd("VimResized", {
			group = patterns.explain_au,

			callback = function ()
				patterns.update_explain();
				vim.bo[patterns.preview_buf].modifiable = false;
			end
		});

		local inp_timer = vim.uv.new_timer();

		vim.api.nvim_create_autocmd({
			"TextChanged", "TextChangedI",
			"CursorMoved", "CursorMovedI"
		}, {
			group = patterns.explain_au,
			buffer = patterns.input_buf,

			callback = function ()
				inp_timer:stop();
				inp_timer:start(50, 0, vim.schedule_wrap(function ()
					if patterns.explain_mode == 1 then
						patterns.render(patterns.input_buf, patterns.preview_buf);
						vim.bo[patterns.preview_buf].modifiable = false;
					else
						patterns.match();
					end
				end));
			end
		});

		local prv_timer = vim.uv.new_timer();

		vim.api.nvim_create_autocmd({
			"TextChanged", "TextChangedI",
		}, {
			group = patterns.explain_au,
			buffer = patterns.preview_buf,

			callback = function ()
				prv_timer:stop();
				prv_timer:start(50, 0, vim.schedule_wrap(function ()
					if patterns.explain_mode == 2 then
						patterns.match();
					end
				end));
			end
		});

		vim.api.nvim_create_autocmd("WinEnter", {
			group = patterns.explain_au,

			callback = function ()
				local win = vim.api.nvim_get_current_win();

				if win ~= patterns.input_win and win ~= patterns.preview_win then
					patterns.explain_close();
				end
			end
		});

		vim.api.nvim_create_autocmd("WinClosed", {
			pattern = { tostring(patterns.input_win), tostring(patterns.preview_win) },

			callback = function ()
				patterns.explain_close();
			end
		});
	end
};

patterns.setup = function (user_config)
end

return patterns;
