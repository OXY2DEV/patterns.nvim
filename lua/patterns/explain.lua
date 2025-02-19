local explain = {};

local utils = require("patterns.utils");
local spec = require("patterns.spec");

---@type string User set filetype.
explain.usr_ft = "lua_patterns";

---@type integer Source buffer.
explain.src_buffer = vim.api.nvim_get_current_buf();

---@type integer[] Range to apply the change on.
explain.src_range = { 0, 0, 0, 0 };

---@type integer, integer Input area.
explain.input_buf, explain.input_win = nil, nil;

---@type integer, integer Explain/matcher area.
explain.preview_buf, explain.preview_win = nil, nil;

---@type integer Autocmd group.
explain.au = vim.api.nvim_create_augroup("patterns.explain", { clear = true });
---@type integer Namespace.
explain.ns = vim.api.nvim_create_namespace("patterns.explain");

local function rel_index (list, index)
	if index <= #list then
		return index;
	else
		return (index % #list) + 1;
	end
end

--- Explainer mode.
---@type
---| 1 Show explanation.
---| 2 Matcher.
explain.mode = 1;

---@type string[] Cached lines for the matcher.
explain.__lines = nil;
---@type [ integer, integer ] Cursor position for the matcher.
explain.__pos = nil;

--- Float layout.
---@param ft string
explain.__layout_float = function (ft)
	---|fS

	local input_spec = spec.get({ "windows", "explain_input" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = 1,

			border = "rounded"
		}
	});

	local preview_spec = spec.get({ "windows", "explain_preview" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = 15,

			border = "rounded"
		}
	});

	local inH = input_spec.border and input_spec.height + 2 or input_spec.height;
	local pvH = preview_spec.border and preview_spec.height + 2 or preview_spec.height;

	local grY = math.floor((vim.o.lines - (inH + pvH)) / 2);

	local input_winconfig = {
		relative = "editor",
		style = "minimal",

		row = grY,
		col = math.floor((vim.o.columns - input_spec.width) / 2),

		width = input_spec.width,
		height = input_spec.height,

		border = input_spec.border,

		title_pos = "right",
		title = {
			{
				string.format(" %s%s ", input_spec.title_icon or " ", ft),
				input_spec.title_hl or "PatternsPalette0"
			}
		}
	};

	local preview_winconfig = {
		relative = "editor",
		style = "minimal",

		row = grY + inH,
		col = math.floor((vim.o.columns - input_spec.width) / 2),

		width = preview_spec.width,
		height = preview_spec.height,

		border = preview_spec.border,

		footer_pos = "right",
		footer = {
			{ " " },
			{
				" 󰂖 Explain ",
				explain.mode == 1 and (preview_spec.active_hl or "PatternsPalette7") or (preview_spec.inactive_hl or "PatternsPalette0")
			},
			{ " " },
			{
				" 󰄺 Match ",
				explain.mode == 2 and (preview_spec.active_hl or "PatternsPalette7") or (preview_spec.inactive_hl or "PatternsPalette0")
			},
			{ " " },
		}
	};

	if not explain.input_win or vim.api.nvim_win_is_valid(explain.input_win) == false then
		explain.input_win = vim.api.nvim_open_win(explain.input_buf, true, input_winconfig);
	else
		vim.api.nvim_win_set_config(explain.input_win, input_winconfig);
	end

	if not explain.preview_win or vim.api.nvim_win_is_valid(explain.preview_win) == false then
		explain.preview_win = vim.api.nvim_open_win(explain.preview_buf, false, preview_winconfig);
	else
		vim.api.nvim_win_set_config(explain.preview_win, preview_winconfig);
	end

	if input_winconfig.border_hl then
		vim.wo[explain.input_win].winhl = "FloatBorder:" .. input_winconfig.border_hl;
	end

	if preview_winconfig.border_hl then
		vim.wo[explain.preview_win].winhl = "FloatBorder:" .. preview_winconfig.border_hl;
	end

	---|fE
end

--- Split layout.
---@param ft string
explain.__layout_split = function (ft)
	---|fS

	local input_spec = spec.get({ "windows", "explain_input" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = 1,

			split = "below",
			border = "rounded"
		}
	});

	local preview_spec = spec.get({ "windows", "explain_preview" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = 15,

			split = "right",
			border = "rounded"
		}
	});

	local inH = input_spec.height;
	local pvH = preview_spec.height;

	local input_winconfig = {
		split = input_spec.split,
		style = "minimal",

		width = input_spec.width,
		height = math.max(inH, pvH),
	};

	local preview_winconfig = {
		split = preview_spec.split,
		win = explain.input_win,
		style = "minimal",

		width = preview_spec.width,
		height = math.max(inH, pvH),
	};

	if not explain.input_win or vim.api.nvim_win_is_valid(explain.input_win) == false then
		explain.input_win = vim.api.nvim_open_win(explain.input_buf, true, input_winconfig);
	else
		vim.api.nvim_win_set_config(explain.input_win, input_winconfig);
	end

	if not explain.preview_win or vim.api.nvim_win_is_valid(explain.preview_win) == false then
		explain.preview_win = vim.api.nvim_open_win(explain.preview_buf, false, preview_winconfig);
	else
		vim.api.nvim_win_set_config(explain.preview_win, preview_winconfig);
	end

	vim.wo[explain.input_win].statusline = table.concat({
		"%#Normal#",
		input_spec.title_hl and ("%#" .. input_spec.title_hl .. "#") or "%#PatternsPalette0#",
		" ",
		input_spec.title_icon or " ",
		ft,
		" ",
		"%#Normal#",
	});

	vim.wo[explain.preview_win].statusline = table.concat({
		"%#Normal#",
		"%=",
		" ",
		explain.mode == 1 and (preview_spec.active_hl or "%#PatternsPalette7#") or (preview_spec.inactive_hl or "%#PatternsPalette0#"),
		" 󰂖 Explain ",
		"%#Normal#",
		" ",
		explain.mode == 2 and (preview_spec.active_hl or "%#PatternsPalette7#") or (preview_spec.inactive_hl or "%#PatternsPalette0#"),
		" 󰄺 Match ",
		" ",
	});

	---|fE
end

--- Update window position.
explain.update_winpos = function ()
	---|fS

	if not explain.input_buf or vim.api.nvim_buf_is_valid(explain.input_buf) == false then
		explain.input_buf = vim.api.nvim_create_buf(false, true);
	end

	if not explain.preview_buf or vim.api.nvim_buf_is_valid(explain.preview_buf) == false then
		explain.preview_buf = vim.api.nvim_create_buf(false, true);
	end

	local layout = spec.get({ "windows", "explain_layoout" }, { fallback = "float" });

	if explain.tmp_layout then
		layout = explain.tmp_layout;
	else
		explain.tmp_layout = layout;
	end

	if layout == "float" then
		explain.__layout_float(explain.supported_fts[explain.usr_ft or "lua_patterns"]);
	else
		explain.__layout_split(explain.supported_fts[explain.usr_ft or "lua_patterns"])
	end

	vim.wo[explain.preview_win].scrolloff = 999;
	vim.wo[explain.preview_win].sidescrolloff = 999;

	if vim.list_contains({ explain.input_win, explain.preview_win }, vim.api.nvim_get_current_win()) == false then
		vim.api.nvim_set_current_win(explain.input_win);
	end

	---|fE
end

--- TODO, Do we need this abstraction?
--- Supported filetypes.
---@type table<string, string>
explain.supported_fts = {
	lua_patterns = "LuaPatterns",
	regex = "RegexPatterns"
};

--- Matchers
---@type table<string, function>
explain.matcher = {
	regex = function ()
		local input = table.concat(vim.api.nvim_buf_get_lines(explain.input_buf, 0, -1, false), "");

		if input == "" then
			return;
		elseif pcall(vim.fn.matchlist, "lorem ipsum", input) == false then
			return;
		end

		---@type string[]
		local match_hl = spec.get({ "regex", "match_hl" }, { fallback = { "PatternsPalette1", "PatternsPalette2", "PatternsPalette3", "PatternsPalette4", "PatternsPalette5", "PatternsPalette6", "PatternsPalette7" } });

		for l, line in ipairs(vim.api.nvim_buf_get_lines(explain.preview_buf, 0, -1, false)) do
			if string.match(line, "^%s*$") then
				goto continue;
			end

			local matches = vim.fn.matchlist(line, input) or {};
			local _v = {};

			local _line = line;
			local offset = 0;

			matches = vim.tbl_filter(function (val)
				return val ~= "" and val ~= line;
			end, matches);

			for m, match in ipairs(matches) do
				local col_start, col_end = string.find(_line, match, 1, true);

				if not col_start then
					goto skip;
				end

				---@type string
				local hl = match_hl[rel_index(match_hl, m)];

				vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, (col_start + offset) - 1, {
					invalidate = true, undo_restore = false,
					end_col = col_end + offset,

					hl_group = hl,
				});

				table.insert(_v, {
					{ (m == #matches and "└─" or "├─"), "PatternsPalette0Fg" },
					{ string.format(" 󰾹 %s ", vim.inspect(match)), hl }
				});

				_line = string.gsub(_line, utils.escape_string(match), "", 1);
				offset = offset + #match;

				::skip::
			end

			vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, 0, {
				invalidate = true, undo_restore = false,
				virt_lines = _v
			});

			vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, 0, {
				invalidate = true, undo_restore = false,

				virt_text_pos = "right_align",
				virt_text = #matches ~= 0 and {
					{ "󰄲 ", "DiagnosticOk" }
				} or {
					{ "󰄮 ", "DiagnosticError" }
				}
			});

			::continue::
		end
	end,
	lua_patterns = function ()
		local input = table.concat(vim.api.nvim_buf_get_lines(explain.input_buf, 0, -1, false), "");

		if input == "" then
			return;
		elseif pcall(string.match, "lorem ipsum", input) == false then
			return;
		end

		---@type string[]
		local match_hl = spec.get({ "lua_patterns", "match_hl" }, { fallback = { "PatternsPalette1", "PatternsPalette2", "PatternsPalette3", "PatternsPalette4", "PatternsPalette5", "PatternsPalette6", "PatternsPalette7" } });

		for l, line in ipairs(vim.api.nvim_buf_get_lines(explain.preview_buf, 0, -1, false)) do
			if string.match(line, "^%s*$") then
				goto continue;
			end

			local _line = line;
			local offset = 0;

			local matches = { string.match(line, input) };
			local _v = {};

			for m, match in ipairs(matches) do
				local col_start, col_end = string.find(_line, match, 1, true);

				if not col_start then
					goto skip;
				end

				---@type string
				local hl = match_hl[rel_index(match_hl, m)];

				vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, (col_start + offset) - 1, {
					invalidate = true, undo_restore = false,
					end_col = col_end + offset,

					hl_group = hl,
				});

				table.insert(_v, {
					{ (m == #matches and "└─" or "├─"), "PatternsPalette0Fg" },
					{ string.format(" 󰾹 %s ", vim.inspect(match)), hl }
				});

				_line = string.gsub(_line, utils.escape_string(match), "", 1);
				offset = offset + #match;

				::skip::
			end

			vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, 0, {
				invalidate = true, undo_restore = false,
				virt_lines = _v
			});

			vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, 0, {
				invalidate = true, undo_restore = false,

				virt_text_pos = "right_align",
				virt_text = line ~= _line and {
					{ "󰄲 ", "DiagnosticOk" }
				} or {
					{ "󰄮 ", "DiagnosticError" }
				}
			});

			::continue::
		end
	end,

	init = function ()
		vim.api.nvim_buf_clear_namespace(explain.preview_buf, explain.ns, 0, -1);

		if not explain.matcher[explain.usr_ft or "lua_patterns"] then
			return;
		elseif explain.mode ~= 2 then
			return;
		end

		explain.matcher[explain.usr_ft or "lua_patterns"]();
	end
};

explain.render = function ()
	if explain.mode ~= 1 then
		return;
	end

	vim.bo[explain.preview_buf].modifiable = true;
	vim.api.nvim_buf_set_lines(explain.preview_buf, 0, -1, false, {});

	local content = require("patterns.parser").parse(explain.input_buf);
	local _c = require("patterns.renderer").render(explain.preview_buf, content);

	vim.bo[explain.preview_buf].modifiable = false;
	pcall(vim.api.nvim_win_set_cursor, explain.preview_win, { _c, 0 });
end

explain.clear = function ()
	vim.bo[explain.preview_buf].modifiable = true;

	vim.api.nvim_buf_set_lines(explain.preview_buf, 0, -1, false, {});
	require("patterns.renderer").clear(explain.preview_buf);
end

explain.close = function ()
	explain.au = vim.api.nvim_create_augroup("patterns.explain", { clear = true });

	if explain.mode == 2 then
		explain.__lines = vim.api.nvim_buf_get_lines(explain.preview_buf, 0, -1, false);
		explain.__pos = vim.api.nvim_win_get_cursor(explain.preview_win);
	end

	explain.clear();

	pcall(vim.api.nvim_win_close, explain.input_win, true);
	pcall(vim.api.nvim_win_close, explain.preview_win, true);
end

explain.actions = {
	toggle = function ()
		local win = vim.api.nvim_get_current_win();

		if win == explain.preview_win then
			pcall(vim.api.nvim_set_current_win, explain.input_win);
		elseif win == explain.input_win then
			pcall(vim.api.nvim_set_current_win, explain.preview_win);
		end
	end,
	mode_change = function ()
		if explain.mode == 1 then
			explain.mode = 2;

			explain.clear();

			vim.bo[explain.preview_buf].modifiable = true;

			pcall(vim.api.nvim_buf_set_lines, explain.preview_buf, 0, -1, false, explain.__lines);
			pcall(vim.api.nvim_win_set_cursor, explain.preview_win, explain.__pos);

			explain.matcher.init();
		else
			explain.__lines = vim.api.nvim_buf_get_lines(explain.preview_buf, 0, -1, false);
			explain.__pos = vim.api.nvim_win_get_cursor(explain.preview_win);

			explain.clear();

			explain.mode = 1;
			explain.render();
		end

		explain.update_winpos();
	end,
	lang_next = function ()
		local keys = vim.tbl_keys(explain.supported_fts);

		keys = vim.tbl_filter(function (val)
			return utils.parser_installed(val);
		end, keys);

		for i, item in ipairs(keys) do
			if item == explain.usr_ft then
				if (i + 1) > #keys then
					explain.usr_ft = keys[1];
				else
					explain.usr_ft = keys[i + 1];
				end

				vim.bo[explain.input_buf].ft = explain.supported_fts[explain.usr_ft];

				explain.update_winpos();

				if explain.mode == 1 then
					explain.render();
				else
					explain.matcher.init();
				end

				return;
			end
		end
	end,
	lang_prev = function ()
		local keys = vim.tbl_keys(explain.supported_fts);

		keys = vim.tbl_filter(function (val)
			return utils.parser_installed(val);
		end, keys);

		for i, item in ipairs(keys) do
			if item == explain.usr_ft then
				if (i - 1) < 1 then
					explain.usr_ft = keys[#keys];
				else
					explain.usr_ft = keys[i - 1];
				end

				vim.bo[explain.input_buf].ft = explain.supported_fts[explain.usr_ft];

				explain.update_winpos();

				if explain.mode == 1 then
					explain.render();
				else
					explain.matcher.init();
				end

				return;
			end
		end
	end,

	close = explain.close,
	apply = function ()
		local range = explain.src_range or { 0, 0, 0, 0 };

		local input = vim.api.nvim_buf_get_lines(explain.input_buf, 0, -1, false);
		pcall(vim.api.nvim_buf_set_text, explain.src_buffer, range[1], range[2], range[3], range[4], input);

		explain.close();
	end
}

explain.explain = function (ft, text, range, mode, buffer)
	explain.tmp_layout = nil;

	explain.usr_ft = ft or "lua_patterns";
	text = text or "";

	explain.mode = mode or 1;
	explain.src_buffer = buffer or vim.api.nvim_get_current_buf();

	if not range then
		local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win());
		range = { cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] };
	end

	explain.src_range = range;

	if not explain.supported_fts[explain.usr_ft] then
		return;
	end

	explain.update_winpos();

	vim.bo[explain.input_buf].ft = explain.supported_fts[explain.usr_ft];
	vim.api.nvim_buf_set_lines(explain.input_buf, 0, -1, false, vim.islist(text) and text or { text });

	if explain.mode == 1 then
		explain.render();
	else
		vim.bo[explain.preview_buf].modifiable = true;

		vim.api.nvim_buf_set_lines(explain.preview_buf, 0, -1, false, explain.__lines or {});
		explain.matcher.init();
	end

	vim.api.nvim_create_autocmd("VimResized", {
		group = explain.au,

		callback = function ()
			explain.update_winpos();
		end
	});

	local input_timer = vim.uv.new_timer();

	vim.api.nvim_create_autocmd({
		"CursorMoved", "CursorMovedI",
		"TextChanged", "TextChangedI"
	}, {
		group = explain.au,
		buffer = explain.input_buf,

		callback = function ()
			input_timer:stop();
			input_timer:start(60, 0, vim.schedule_wrap(function ()
				if explain.mode == 1 then
					explain.clear();
					explain.render();
				else
					explain.matcher.init();
				end
			end));
		end
	});

	local preview_timer = vim.uv.new_timer();

	vim.api.nvim_create_autocmd({
		"CursorMoved", "CursorMovedI",
		"TextChanged", "TextChangedI"
	}, {
		group = explain.au,
		buffer = explain.preview_buf,

		callback = function ()
			preview_timer:stop();
			preview_timer:start(60, 0, vim.schedule_wrap(function ()
				if explain.mode == 2 then
					explain.matcher.init();
				end
			end));
		end
	});

	vim.api.nvim_create_autocmd({ "WinClosed" }, {
		pattern = { tostring(explain.input_win), tostring(explain.preview_win) },

		callback = function ()
			explain.close();
		end
	});

	local keymaps = spec.get({ "keymaps" }, { fallback = {} });

	for lhs, map in pairs(keymaps.explain_input or {}) do
		local callback = map.callback;

		if type(callback) == "string" then
			if explain.actions[callback] then
				callback = explain.actions[callback];
			else
				callback = nil;
			end
		end

		vim.api.nvim_buf_set_keymap(
			explain.input_buf,
			map.mode or "n",
			lhs,
			map.rhs or "",
			{
				desc = map.desc,
				callback = callback
			}
		);
	end

	for lhs, map in pairs(keymaps.explain_preview or {}) do
		local callback = map.callback;

		if type(callback) == "string" then
			if explain.actions[callback] then
				callback = explain.actions[callback];
			else
				callback = nil;
			end
		end

		vim.api.nvim_buf_set_keymap(
			explain.preview_buf,
			map.mode or "n",
			lhs,
			map.rhs or "",
			{
				desc = map.desc,
				callback = callback
			}
		);
	end
end

return explain;
