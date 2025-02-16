local explain = {};
local spec = require("patterns.spec");

explain.input_buf, explain.input_win = nil, nil;

explain.preview_buf, explain.preview_win = nil, nil;

explain.au = vim.api.nvim_create_augroup("patterns.explain", { clear = true });
explain.ns = vim.api.nvim_create_namespace("patterns.explain");

explain.mode = 1;

explain.__lines = nil;
explain.__pos = nil;

explain.__layout_float = function (ft)
	local input_spec = spec.get({ "windows", "input" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = 1,

			border = "rounded"
		}
	});

	local preview_spec = spec.get({ "windows", "preview" }, {
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
				explain.mode == 1 and (preview_spec.active_hl or "PatternsPalette7") or (input_spec.inactive_hl or "PatternsPalette0")
			},
			{ " " },
			{
				" 󰄺 Match ",
				explain.mode == 2 and (preview_spec.active_hl or "PatternsPalette7") or (input_spec.inactive_hl or "PatternsPalette0")
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
end

explain.__layout_split = function (ft)
	local input_spec = spec.get({ "windows", "input" }, {
		fallback = {
			width = math.floor(vim.o.columns * 0.6),
			height = 1,

			split = "below",
			border = "rounded"
		}
	});

	local preview_spec = spec.get({ "windows", "preview" }, {
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
		explain.mode == 1 and (preview_spec.active_hl or "%#PatternsPalette7#") or (input_spec.inactive_hl or "%#PatternsPalette0#"),
		" 󰂖 Explain ",
		"%#Normal#",
		" ",
		explain.mode == 2 and (preview_spec.active_hl or "%#PatternsPalette7#") or (input_spec.inactive_hl or "%#PatternsPalette0#"),
		" 󰄺 Match ",
		" ",
	});
end

explain.update_winpos = function (ft)
	if not explain.input_buf or vim.api.nvim_buf_is_valid(explain.input_buf) == false then
		explain.input_buf = vim.api.nvim_create_buf(false, true);
	end

	if not explain.preview_buf or vim.api.nvim_buf_is_valid(explain.preview_buf) == false then
		explain.preview_buf = vim.api.nvim_create_buf(false, true);
	end

	local layout = spec.get({ "windows", "explain_layoout" }, { fallback = "float" });

	if layout == "float" then
		explain.__layout_float(ft);
	else
		explain.__layout_split(ft)
	end

	if vim.list_contains({ explain.input_win, explain.preview_win }, vim.api.nvim_get_current_win()) == false then
		vim.api.nvim_set_current_win(explain.input_win);
	end
end

explain.supported_fts = {
	lua_patterns = "LuaPatterns",
	regex = "RegexPatterns"
};

explain.matcher = {
	regex = function ()
		local input = table.concat(vim.api.nvim_buf_get_lines(explain.input_buf, 0, -1, false), "\n");

		if input == "" then
			return;
		end

		local regex = vim.regex(input);

		for l, line in ipairs(vim.api.nvim_buf_get_lines(explain.preview_buf, 0, -1, false)) do
			if string.match(line, "^%s*$") then
				goto continue;
			end

			local can_match, from, to = pcall(regex.match_str, regex, line, input);

			if not from and not to then
				can_match = false;
			else
				vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, from, {
					invalidate = true, undo_restore = false,
					end_col = to,

					hl_group = "DiagnosticOk"
				});
			end

			vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, 0, {
				invalidate = true, undo_restore = false,

				virt_text_pos = "right_align",
				virt_text = can_match and {
					{ "󰄲 ", "DiagnosticOk" }
				} or {
					{ "󰄮 ", "DiagnosticError" }
				}
			});

			::continue::
		end
	end,
	lua_patterns = function ()
		local input = table.concat(vim.api.nvim_buf_get_lines(explain.input_buf, 0, -1, false), "\n");

		if input == "" then
			return;
		end

		for l, line in ipairs(vim.api.nvim_buf_get_lines(explain.preview_buf, 0, -1, false)) do
			if string.match(line, "^%s*$") then
				goto continue;
			end

			local can_match = pcall(string.match, line, input);
			local matches = { string.match(line, input) };

			if #matches == 0 then
				can_match = false;
			end

			local _line = line;
			local offset = 0;

			while #matches > 0 do
				local from, to = string.find(_line, matches[1]);
				_line = _line:gsub(matches[1], "", 1);

				vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, (from + offset) - 1, {
					invalidate = true, undo_restore = false,
					end_col = to + offset,

					hl_group = "DiagnosticOk"
				});

				offset = offset + #matches[1];
				table.remove(matches, 1);
			end

			vim.api.nvim_buf_set_extmark(explain.preview_buf, explain.ns, l - 1, 0, {
				invalidate = true, undo_restore = false,

				virt_text_pos = "right_align",
				virt_text = can_match and {
					{ "󰄲 ", "DiagnosticOk" }
				} or {
					{ "󰄮 ", "DiagnosticError" }
				}
			});

			::continue::
		end
	end,

	init = function (ft)
		vim.api.nvim_buf_clear_namespace(explain.preview_buf, explain.ns, 0, -1);

		if not explain.matcher[ft] then
			return;
		elseif explain.mode ~= 2 then
			return;
		end

		explain.matcher[ft]();
	end
};

explain.render = function ()
	if explain.mode ~= 1 then
		return;
	end

	vim.bo[explain.preview_buf].modifiable = true;
	vim.api.nvim_buf_set_lines(explain.preview_buf, 0, -1, false, {});

	local content = require("patterns.parser").parse(explain.input_buf);
	require("patterns.renderer").render(explain.preview_buf, content);

	vim.bo[explain.preview_buf].modifiable = false;
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

explain.explain = function (ft, text, range, mode)
	ft = ft or "lua_patterns";
	text = text or "";

	explain.mode = mode or 1;

	if not range then
		local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win());
		range = { cursor[1], cursor[2], cursor[1], cursor[2] };
	end

	if not explain.supported_fts[ft] then
		return;
	end

	explain.update_winpos(ft);

	vim.bo[explain.input_buf].ft = explain.supported_fts[ft];
	vim.api.nvim_buf_set_lines(explain.input_buf, 0, -1, false, { text });

	if explain.mode == 1 then
		explain.render();
	else
		vim.bo[explain.preview_buf].modifiable = true;

		vim.api.nvim_buf_set_lines(explain.preview_buf, 0, -1, false, explain.__lines or {});
		explain.matcher.init(ft);
	end

	vim.api.nvim_create_autocmd("VimResized", {
		group = explain.au,

		callback = function ()
			explain.update_winpos(ft);
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
					explain.matcher.init(ft);
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
					explain.matcher.init(ft);
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

	vim.api.nvim_buf_set_keymap(explain.input_buf, "n", "H", "", {
		callback = function ()
			---|fS "Switch parser language"

			local keys = vim.tbl_keys(explain.supported_fts);

			for i, item in ipairs(keys) do
				if item == ft then
					if (i + 1) > #keys then
						ft = keys[1];
					else
						ft = keys[i + 1];
					end

					vim.bo[explain.input_buf].ft = explain.supported_fts[ft];

					explain.update_winpos(ft);

					if explain.mode == 1 then
						explain.render();
					else
						explain.matcher.init(ft);
					end

					return;
				end
			end

			---|fE
		end
	});

	vim.api.nvim_buf_set_keymap(explain.input_buf, "n", "L", "", {
		callback = function ()
			---|fS "Switch parser language"

			local keys = vim.tbl_keys(explain.supported_fts);

			for i, item in ipairs(keys) do
				if item == ft then
					if (i - 1) < 1 then
						ft = keys[#keys];
					else
						ft = keys[i - 1];
					end

					vim.bo[explain.input_buf].ft = explain.supported_fts[ft];

					explain.update_winpos(ft);

					if explain.mode == 1 then
						explain.render();
					else
						explain.matcher.init(ft);
					end

					return;
				end
			end

			---|fE
		end
	});

	vim.api.nvim_buf_set_keymap(explain.input_buf, "n", "<tab>", "", {
		callback = function ()
			vim.api.nvim_set_current_win(explain.preview_win);
		end
	});

	vim.api.nvim_buf_set_keymap(explain.preview_buf, "n", "<tab>", "", {
		callback = function ()
			vim.api.nvim_set_current_win(explain.input_win);
		end
	});

	vim.api.nvim_buf_set_keymap(explain.input_buf, "n", "q", "", {
		callback = function ()
			explain.close();
		end
	});

	vim.api.nvim_buf_set_keymap(explain.preview_buf, "n", "q", "", {
		callback = function ()
			explain.close();
		end
	});

	vim.api.nvim_buf_set_keymap(explain.preview_buf, "n", "T", "", {
		callback = function ()
			if explain.mode == 1 then
				explain.mode = 2;

				explain.clear();

				vim.bo[explain.preview_buf].modifiable = true;

				pcall(vim.api.nvim_buf_set_lines, explain.preview_buf, 0, -1, false, explain.__lines);
				pcall(vim.api.nvim_win_set_cursor, explain.preview_win, explain.__pos);

				explain.matcher.init(ft);
			else
				explain.__lines = vim.api.nvim_buf_get_lines(explain.preview_buf, 0, -1, false);
				explain.__pos = vim.api.nvim_win_get_cursor(explain.preview_win);

				explain.clear();

				explain.mode = 1;
				explain.render();
			end

			explain.update_winpos(ft);
		end
	});
end

return explain;
