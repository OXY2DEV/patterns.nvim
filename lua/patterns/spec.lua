local spec = {};

local on_current = function (_, item)
	return item.current == true;
end

---@type patterns.config
spec.default = {
	preferred_regex_matcher = "vim",
	update_delay = 150,

	keymaps = {
		explain_input = {
			["<CR>"] = {
				callback = "apply"
			},
			["q"] = {
				callback = "close"
			},

			["<tab>"] = {
				callback = "toggle"
			},

			["H"] = {
				callback = "lang_prev"
			},
			["L"] = {
				callback = "lang_next"
			},
		},
		explain_preview = {
			["q"] = {
				callback = "close"
			},

			["<tab>"] = {
				callback = "toggle"
			},

			["T"] = {
				callback = "mode_change"
			}
		},

		hover = {
			["q"] = {
				callback = "close"
			},
			["i"] = {
				callback = "edit"
			}
		}
	},
	windows = {
		hover = function (q1, q2)
			local border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" };

			if q2 == "top" then
				if q1 == "left" then
					border[5] = "┤";
				elseif q1 == "right" then
					border[7] = "├";
				end
			elseif q2 == "bottom" then
				if q1 == "left" then
					border[3] = "┤";
				elseif q1 == "right" then
					border[1] = "├";
				end
			end

			local ft = "Patterns";

			if package.loaded["patterns.hover"] and package.loaded["patterns.hover"].buf then
				local _ft = vim.bo[package.loaded["patterns.hover"].buf].ft;
				local r_map = {
					regex = "Regex",
					lua_patterns = "LuaPatterns"
				};

				ft = r_map[_ft] or "Patterns";
			end

			return {
				width = math.floor(vim.o.columns * 0.6),
				height = math.floor(vim.o.lines * 0.5),

				border = border,

				footer_pos = "right",
				footer = {
					{ "╸", "FloatBorder" },
					{ " 󰛪 " .. ft .. " ", "FloatBorder" },
					{ "╺", "FloatBorder" },
				}
			}
		end,
		explain_preview = function ()
			return {
				active_hl = "PatternsPalette7Fg",
				inactive_hl = "PatternsPalette0Fg",

				width = math.floor(vim.o.columns * 0.6),
				height = 15,

				border = "rounded"
			};
		end
	},

	lua_patterns = {
		indent_size = 2,
		indent_marker = "│",
		indent_hl = "PatternsPalette0Fg",

		pattern = {
			text = "󰐱 Pattern",
			show_tip = on_current,

			tip_hl = "PatternsPalette0Bg",
			hl = "PatternsPalette0";
		},

		----------------------------------------

		anchor_start = {
			text = "󰾺 From start",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		anchor_end = {
			text = "󰾸 To end",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		----------------------------------------

		quantifier_minus = {
			text = "󰑖 Zero or more times(non-greedily)",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_optional = {
			text = "󰑘 Zero or one time",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_plus = {
			text = "󰑘 One or more times",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_star = {
			text = "󰑖 Zero or more times(greedily)",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		----------------------------------------

		literal_character = {
			text = function (_, item)
				if item.text == "\\" then
					return '󱄽 Character: "\\"';
				else
					return string.format("󱄽 Character: %s", vim.inspect(item.text));
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette4Bg",
			hl = "PatternsPalette4"
		},

		any_character = {
			text = " Any character",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		escape_sequence = {
			text = function (_, item)
				return string.format('󰩈 Escape sequence: "%s"', item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		escaped_character = {
			text = function (_, item)
				return string.format('󰩈 Escaped character: "%s"', item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		----------------------------------------

		capture_group = {
			text = function (_, item)
				return string.format(" Capture group, 󱤬 %d", item.id or -1);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		character_set = {
			text = function (_, item)
				if string.match(item.text, "^%[%^") then
					return "󱋍 Negated character set";
				else
					return "󱉓 Character set";
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette3Bg",
			hl = "PatternsPalette3"
		},

		character_set_content = {
			text = "󰆦 Character set content,",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		character_range = {
			text = function (_, item)
				return string.format("󰊱 Character range: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		character_class = {
			text = function (_, item)
				return "󰏗 Character class: " .. vim.inspect(item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette4Bg",
			hl = "PatternsPalette4"
		},
	},

	regex = {
		indent_size = 2,
		indent_marker = "│",
		indent_hl = "PatternsPalette0Fg",

		pattern = {
			text = "󰛪 Pattern",
			show_tip = on_current,

			tip_hl = "PatternsPalette0Bg",
			hl = "PatternsPalette0"
		},

		alternation = {
			text = "󰋰 Alternative pattern(s)",
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		term = {
			text = function (_, item)
				return string.format("󰊲 Regex term(#%d)", item.id or -1);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		----------------------------------------

		start_assertion = {
			text = "󰾺 From start",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		end_assertion = {
			text = "󰾸 To end",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		boundary_assertion = {
			text = "󰕤 Match as a word",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		non_boundary_assertion = {
			text = "󰕛 Match as part of a word",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		lookaround_assertion = {
			text = function (_, item)
				if string.match(item.text, "^%(%?%<") then
					return "󰡭 Look behind";
				else
					return "󰡮 Look ahead";
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette3Bg",
			hl = "PatternsPalette3"
		},

		----------------------------------------

		quantifier_count = {
			text = function (_, item)
				if string.match(item.text, "^%d+$") then
					return string.format(" Repeats exactly %s times", item.text);
				elseif string.match(item.text, "^%d+,$") then
					return string.format(
						" Repeats at least %s times",
						string.match(item.text, "^(%d+)")
					);
				elseif string.match(item.text, "^,%d+$") then
					return string.format(
						" Repeats at most %s times",
						string.match(item.text, "^,(%d+)$")
					);
				else
					return string.format(
						" Repeats between %s & %s times",
						string.match(item.text, "^(%d+),"),
						string.match(item.text, "^%d+,(%d+)$")
					);
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_optional = {
			text = " Repeats zero or one time",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_plus = {
			text = " Repeats one or more times",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_star = {
			text = " Repeats zero or more times",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		----------------------------------------

		pattern_character = {
			text = function (_, item)
				return string.format("󱄽 Character: %s", vim.inspect(item.text));
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},

		class_character = {
			text = function (_, item)
				return string.format("󱄽 Character: %s", vim.inspect(item.text));
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},

		any_character = {
			text = " Any character",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		decimal_escape = {
			text = function (_, item)
				return string.format("󰩈 Decimal escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		character_class_escape = {
			text = function (_, item)
				return string.format("󰩈 Character class escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		unicode_character_escape = {
			text = function (_, item)
				return string.format("󰩈 Unicode character escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		unicode_property_value = {
			text = function (_, item)
				return string.format("󰗊 Unicode property value: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		control_escape = {
			text = function (_, item)
				return string.format("󰁨 Control character escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		control_letter_escape = {
			text = function (_, item)
				return string.format("󰁨 Control letter escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		identity_escape = {
			text = function (_, item)
				return string.format("󰩈 Identity escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		backreference_escape = {
			text = function (_, item)
				return string.format("󰒻 Backreference escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		----------------------------------------

		unicode_property_value_expression = {
			text = "󰁀 Unicode property value expression",
			show_tip = on_current,

			-- show_content = true,
			tip_hl = "PatternsPalette0Bg",
			hl = "PatternsPalette0"
		},

		----------------------------------------

		character_class = {
			text = "󰏗 Character class",
			show_tip = on_current,

			tip_hl = "PatternsPalette4Bg",
			hl = "PatternsPalette4"
		},

		posix_character_class = {
			text = function (_, item)
				return string.format("󰏗 POSIX Character class: ", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		named_group_backreference = {
			text = function (_, item)
				return string.format("󰒻 Named backreference: ", string.match(item.text, "^%(%?P%=(.-)%)$"));
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		capturing_group = {
			text = function (_, item)
				if type(item.id) == "string" then
					return string.format("󱉶 Capture group(#%s)", item.id or "???");
				else
					return string.format("󱉶 Capture group(#%d)", item.id or -1);
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		non_capturing_group = {
			text = function (_, item)
				return string.format("󰒉 Non-capture group(#%d)", item.id or -1);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		flags_group = {
			text = "󰂖 Flags group",
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},

		flags = {
			text = function (_, item)
				return string.format("󰈻 Flag(s): %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},
	}
};

spec.config = vim.deepcopy(spec.default);

--- Setup function.
---@param config patterns.config | nil
spec.setup = function (config)
	if type(config) ~= "table" then
		return;
	end

	spec.config = vim.tbl_deep_extend("force", spec.config, config);
end

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
		val = to_static(val[key], get_arg(k));

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
