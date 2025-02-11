local spec = {};

spec.default = {
	regex_filetypes = {},
	luap_filetypes = { "lua" },

	windows = {
		input = function ()
			local w = math.floor(
				math.max(vim.o.columns * 0.5, 10)
			);
			local h = math.ceil(vim.o.lines * 0.5);

			local pt = package.loaded["patterns"];

			if (pt and pt.preview_buf) and vim.api.nvim_buf_is_valid(pt.preview_buf) then
				local line_count = vim.api.nvim_buf_line_count(pt.preview_buf);

				if line_count + 5 < h then
					h = line_count + 5;
				end
			end

			local row = math.floor((vim.o.lines - vim.o.cmdheight - h) / 2);
			local col = math.floor((vim.o.columns - w) / 2);

			return {
				relative = "editor",

				width = w,
				height = 1,

				row = row,
				col = col,

				title = {
					{ " 󰗊 Pattern ", "PatternsPalette0" }
				},
				title_pos = "right",

				border = {
					{ "╭", "PatternsInputBorder" },
					{ "─", "PatternsInputBorder" },
					{ "╮", "PatternsInputBorder" },
					{ "│", "PatternsInputBorder" },
					{ "╯", "PatternsInputBorder" },
					{ "─", "PatternsInputBorder" },
					{ "╰", "PatternsInputBorder" },
					{ "│", "PatternsInputBorder" },
				},
				style = "minimal",
			};
		end,
		preview = function ()
			local w = math.floor(
				math.max(vim.o.columns * 0.5, 10)
			);
			local h = math.ceil(vim.o.lines * 0.5);
			local pt = package.loaded["patterns"];

			if (pt and pt.preview_buf) and vim.api.nvim_buf_is_valid(pt.preview_buf) then
				local line_count = vim.api.nvim_buf_line_count(pt.preview_buf);

				if line_count + 5 < h then
					h = line_count + 5;
				end
			end

			local row = math.floor((vim.o.lines - vim.o.cmdheight - h) / 2);
			local col = math.floor((vim.o.columns - w) / 2);

			return {
				relative = "editor",

				width = w,
				height = h - 5,

				row = row + 3,
				col = col,

				title = {
					{ " 󰈈 Preview ", "PatternsPalette7" }
				},
				title_pos = "right",

				footer = {
					{ "─", "PatternsPreviewBorder" },
					{ " " },
					{ "[J]", "PatternsPalette4" },
					{ ": Down, ", "Comment" },
					{ "[L]", "PatternsPalette4" },
					{ ": Up", "Comment" },
					{ " " },
					{ "─", "PatternsPreviewBorder" },
				},
				footer_pos = "right",

				border = {
					{ "╭", "PatternsPreviewBorder" },
					{ "─", "PatternsPreviewBorder" },
					{ "╮", "PatternsPreviewBorder" },
					{ "│", "PatternsPreviewBorder" },
					{ "╯", "PatternsPreviewBorder" },
					{ "─", "PatternsPreviewBorder" },
					{ "╰", "PatternsPreviewBorder" },
					{ "│", "PatternsPreviewBorder" },
				},
				style = "minimal"
			};
		end
	},

	lua_patterns = {
		indent_size = 4,
		indent_marker = "│",
		indent_hl = "Comment",

		pattern = {
			text = "󰛪 Pattern",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette0Bg",
			hl = "PatternsPalette0"
		},

		----------------------------------------

		anchor_start = {
			text = "󰀱 From start",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette3Bg",
			hl = "PatternsPalette3"
		},

		anchor_end = {
			text = "󰀱 To end",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette3Bg",
			hl = "PatternsPalette3"
		},

		----------------------------------------

		quantifier_minus = {
			text = " Repeats zero or more times(non-greedily)",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_optional = {
			text = " Repeats zero or one time",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_plus = {
			text = " Repeats one or more times",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_star = {
			text = " Repeats zero or more times",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		----------------------------------------

		character = {
			text = "󱄽 Character:",
			show_range = function (_, item)
				return item.current == true;
			end,

			show_content = true,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},

		any = {
			text = " Any character",

			show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		escape_sequence = {
			text = "󰩈 Escape sequence:",
			show_range = function (_, item)
				return item.current == true;
			end,

			show_content = true,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		escaped_character = {
			text = "󰩈 Escaped character:",
			show_range = function (_, item)
				return item.current == true;
			end,

			show_content = true,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		----------------------------------------

		character_set = {
			text = "󰀁 Character set:",

			-- show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		character_set_content = {
			text = "󰆦 Set content:",

			-- show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		capture_group = {
			text = function (_, item)
				return string.format("󱉶 Capture group(#%d)", item.id or -1);
			end,

			-- show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		character_range = {
			text = "󰊱 Character range:",

			-- show_content = false,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		character_class = {
			text = "󰏗 Character class:",

			show_content = true,
			range_hl = "Comment",
			indent_hl = "Comment",

			tip_hl = "PatternsPalette4Bg",
			hl = "PatternsPalette4"
		},
	}
};

spec.config = vim.deepcopy(spec.default);

--- Function to retrieve configuration options
--- from a config table.
---@param keys ( string | integer )[]
---@param opts spec.options
---@return any
spec.get = function (keys, opts)
	---+${lua}

	--- In case the values are correctly provided..
	keys = keys or {};
	opts = opts or {};

	--- Turns a dynamic value into
	--- a static value.
	---@param val any | fun(...): any
	---@param args any[]?
	---@return any
	local function to_static(val, args)
		---+${lua}

		if type(val) ~= "function" then
			return val;
		end

		args = args or {};

		---@diagnostic disable
		if pcall(val, unpack(args)) then
			return val(unpack(args));
		else
			-- vim.print(pcall(val, unpack(args)))
		end
		---@diagnostic enable

		return val;
		---_
	end

	---@param index integer | string
	---@return any
	local function get_arg(index)
		---+${lua}
		if type(opts.args) ~= "table" then
			return {};
		elseif opts.args.__is_arg_list == true then
			return opts.args[index];
		else
			return opts.args;
		end
		---_
	end

	--- Temporarily store the value.
	---
	--- Use `deepcopy()` as we may need to
	--- modify this value.
	---@type any
	local val;

	if type(opts.source) == "table" or type(opts.source) == "function" then
		val = opts.source;
	elseif spec.config then
		val = spec.config;
	else
		val = {};
	end

	--- Turn the main value into a static value.
	--- [ In case a function was provided as the source. ]
	val = to_static(val, get_arg("init"));

	if type(val) ~= "table" then
		--- The source isn't a table.
		return opts.fallback;
	end

	for k, key in ipairs(keys) do
		val = to_static(val[key], val.args);

		if k ~= #keys then
			if type(val) ~= "table" then
				return opts.fallback;
			elseif opts.ignore_enable ~= true and val.enable == false then
				return opts.fallback;
			end
		end
	end

	if vim.islist(opts.eval_args) == true and type(val) == "table" then
		local _e = {};
		local eval = opts.eval or vim.tbl_keys(val);
		local ignore = opts.eval_ignore or {};

		for k, v in pairs(val) do
			if type(v) ~= "function" then
				--- A silly attempt at reducing
				--- wasted time due to extra
				--- logic.
				_e[k] = v;
			elseif vim.list_contains(ignore, k) == false then
				if vim.list_contains(eval, k) then
					_e[k] = to_static(v, opts.eval_args);
				else
					_e[k] = v;
				end
			else
				_e[k] = v;
			end
		end

		val = _e;
	elseif vim.islist(opts.eval_args) == true and type(val) == "function" then
		val = to_static(val, opts.eval_args);
	end

	if val == nil and opts.fallback then
		return opts.fallback;
	elseif type(val) == "table" and ( opts.ignore_enable ~= true and val.enable == false ) then
		return opts.fallback;
	else
		return val;
	end

	---_
end

return spec;
