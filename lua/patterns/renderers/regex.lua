local regex = {};

local spec = require("patterns.spec");
local utils = require("patterns.utils");

---@type integer Namespace.
regex.ns = vim.api.nvim_create_namespace("patterns/regex");

---@type { [string]: string | fun(buffer: integer, item: __patterns.item): string? }
regex.tips = {
	pattern = "A regex pattern.",
	alternation = "Matches any one of the alternative patterns.",

	start_assertion = "Only match if the pattern is at the beginning of the string.",
	end_assertion = "Only match if the pattern is at the end of the string.",

	boundary_assertion = "Only match if the pattern is an entire word.",
	non_boundary_assertion = "Only match if the pattern is part of an entire word.",

	lookaround_assertion = function (_, item)
		---@type string
		local text = item.text;

		if text:match("^%(%?%=") then
			return "Positive lookahead.\n \n Asserts that the pattern inside matches.";
		elseif text:match("^%(%?%!") then
			return "Negative lookahead.\n \n Asserts that the pattern inside doesn't match.";
		elseif text:match("^%(%?%<%=") then
			return "Positive lookbehind.\n \n Asserts that the pattern inside matches.";
		elseif text:match("^%(%?%<%!") then
			return "Negative lookbehind.\n \n Asserts that the pattern inside doesn't match.";
		end
	end,


	quantifier_count = function (_, item)
		---|fS

		local is_lazy = string.match(item.text, "%?$") ~= nil;
		local desc;

		if is_lazy then
			desc = "This will match as few times as possible(that successfully matches)."
		else
			desc = "This will match as many times as possible."
		end

		if string.match(item.text, "%{(%d+)%}") then
			return string.format(
				"Matches a pattern exactly %s times.",
				string.match(item.text, "^%{(%d+)%}")
			);
		elseif string.match(item.text, "^%{(%d+),%}") then
			return string.format(
				"Matches a pattern at least %s times. \n \n " .. desc,
				string.match(item.text, "^%{(%d+),%}")
			);
		elseif string.match(item.text, "^%{,(%d+)%}") then
			return string.format(
				"Matches a pattern at most %s times. \n \n " .. desc,
				string.match(item.text, "^%{,(%d+)%}")
			);
		else
			return string.format(
				"Matches a pattern between %s & %s times. \n \n " .. desc,
				string.match(item.text, "^%{(%d+),%d+%}"),
				string.match(item.text, "^%{%d+,(%d+)%}")
			);
		end

		---|fE
	end,
	quantifier_optional = function (_, item)
		---|fS

		local is_lazy = string.match(item.text, "%?$") ~= nil;
		local desc;

		if is_lazy then
			desc = "This will match as few times as possible(that successfully matches)."
		else
			desc = "This will match as many times as possible."
		end

		return "Matches a pattern zero or one time. \n \n" .. desc;

		---|fE
	end,
	quantifier_plus = function (_, item)
		---|fS

		local is_lazy = string.match(item.text, "%?$") ~= nil;
		local desc;

		if is_lazy then
			desc = "This will match as few times as possible(that successfully matches)."
		else
			desc = "This will match as many times as possible."
		end

		return "Matches a pattern one or more times.\n \n " .. desc;

		---|fE
	end,
	quantifier_star = function (_, item)
		---|fS

		local is_lazy = string.match(item.text, "%?$") ~= nil;
		local desc;

		if is_lazy then
			desc = "This will match as few times as possible(that successfully matches)."
		else
			desc = "This will match as many times as possible."
		end

		return "Matches a pattern zero or more times.\n \n " .. desc;

		---|fE
	end,

	lazy = "Makes the quantifier lazy(non-greedy).",


	pattern_character = function (_, item)
		return string.format("Matches %s literally.", vim.inspect(item.text));
	end,
	class_character = function (_, item)
		return string.format("Matches %s literally.", vim.inspect(item.text));
	end,
	any_character = "Matches any character.",
	decimal_escape = "A escaped decimal character. \n \n Either used for, \n A) Backreferencing a capture group.\n B) Represent an ASCII character using their decimal value.",
	character_class_escape = "An escaped Unicode character class. \n \n Further information not available.",
	unicode_character_escape = "An escaped Unicode character. \n \n Further information not available.",

	control_escape = function (_, item)
		if string.match(item.text, "^\\x..$") then
			--- Unicode character.
			local code = tonumber(string.match(item.text, "^\\x(..)$"), 16);
			local char = string.char(code);

			return string.format("Matches %s literally.", vim.inspect(char));
		elseif string.match(item.text, "^\\f$") then
			return "Matches a form feed(A less commonly used whitespace character)."
		elseif string.match(item.text, "^\\n$") then
			return "Matches a newline(A whitespace character)."
		elseif string.match(item.text, "^\\r$") then
			return "Matches a carriage return(A whitespace character)."
		elseif string.match(item.text, "^\\t$") then
			return "Matches a <tab>(A whitespace character)."
		elseif string.match(item.text, "^\\v$") then
			return "Matches a vertical tab(A whitespace character)."
		elseif string.match(item.text, "^\\0$") then
			return "Matches a null character."
		else
			return "Unknown character class."
		end
	end,
	control_letter_escape = "A control character that was escaped. \n \n Usually used to match magic characters.",
	identity_escape = "A character that was escaped. \n \n Usually used to match magic characters.",
	escape_sequence = "An escape sequence. Used for special characters(e.g. \\n).",

	backreference_escape = "Missing information!",

	character_class = "Matches any of the character(s) from a set of matches.",
	posix_character_class = function (_, item)
		local _o = { "Matches any of the character(s) from the POSIX character class.", "" };

		if string.match(item.text, "^%[%:alnum%:%]$") then
			table.insert(_o, "Matches any alphanumeric character.");
		elseif string.match(item.text, "^%[%:alpha%:%]$") then
			table.insert(_o, "Matches any alphabetic character.");
		elseif string.match(item.text, "^%[%:digit%:%]$") then
			table.insert(_o, "Matches any digit.");
		elseif string.match(item.text, "^%[%:lower%:%]$") then
			table.insert(_o, "Matches any lowercase letter.");
		elseif string.match(item.text, "^%[%:upper%:%]$") then
			table.insert(_o, "Matches any uppercase letter.");
		elseif string.match(item.text, "^%[%:space%:%]$") then
			table.insert(_o, "Matches any whitespace character.");
		elseif string.match(item.text, "^%[%:punct%:%]$") then
			table.insert(_o, "Matches any punctuation character.");
		elseif string.match(item.text, "^%[%:graph%:%]$") then
			table.insert(_o, "Matches any visible character.");
		elseif string.match(item.text, "^%[%:print%:%]$") then
			table.insert(_o, "Matches any visible character or space.");
		elseif string.match(item.text, "^%[%:xdigit%:%]$") then
			table.insert(_o, "Matches any hexadecimal character.");
		end

		return table.concat(_o, "\n");
	end,
	named_group_backreference = function (_, item)
		return string.format("A capture group named '%s'.", string.match(item.text, "^%(%?P%=(.-)%)$"))
	end,
	capture_group = "A capture group to be used for various string operations.",
	non_capture_group = "A capture group that won't be stoed in memory.\n \n This can't be used for Backreferencing!",
	flags_groups = "A group of regex flags.",
	flags = function (_, item)
		if not item.text:match("[a-zA-Z]") then
			--- No valid flags detected
			return;
		end

		local _o = { "Deteced flags,", "", "Flag  Description", "----- --------------" };

		for flag in string.gmatch(item.text, "[a-zA-Z]") do
			if flag == "i" then
				table.insert(_o, " i     Ignore case");
			elseif flag == "m" then
				table.insert(_o, " m     Multi-line");
			elseif flag == "s" then
				table.insert(_o, " s     . matches \\n");
			elseif flag == "x" then
				table.insert(_o, " x     Verbose");
			elseif flag == "g" then
				table.insert(_o, " g     Global");
			elseif flag == "u" then
				table.insert(_o, " u     Unicode");
			elseif flag == "A" then
				table.insert(_o, " A     ASCII-only");
			else
				table.insert(_o, string.format(" %s     ???", flag));
			end
		end

		table.insert(_o, "----- --------------");

		return table.concat(_o, "\n");
	end,
}

---@param buffer integer
---@param item __patterns.item
---@return nil
regex.__generic = function (buffer, item)
	---|fS

	---@type integer[] { row_start, col_start, row_end, col_end }
	local range = item.range;

	---@type pattern_item.opts_static Config table.
	local config = spec.get({ "regex", item.kind }, {
		fallback = {},
		eval_args = { buffer, item }
	});

	if not config then
		return;
	end

	---@type integer Indent size
	local indent = spec.get({ "regex", "indent_size" }, {
		fallback = 2,
		eval_args = { buffer, item }
	});
	---@type string Indent
	local indent_marker = spec.get({ "regex", "indent_marker" }, {
		fallback = " ",
		eval_args = { buffer, item }
	});
	---@type string? Indent hl
	local indent_hl = spec.get({ "regex", "indent_hl" }, {
		fallback = nil,
		eval_args = { buffer, item }
	});

	local function indent_part()
		return indent_marker .. string.rep(" ", indent - vim.fn.strchars(indent_marker))
	end

	---@type integer Number of lines this item takes.
	local line_count = 1;

	--- Render the main text.
	vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {
		table.concat({
			" ",
			config.text or item.text
		})
	});

	if item.current == true then
		local win = utils.win_findbuf(buffer);
		pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(buffer) - 1, 0 });
	end

	vim.api.nvim_buf_set_extmark(buffer, regex.ns, vim.api.nvim_buf_line_count(buffer) - line_count, 0, {
		invalidate = true, undo_restore = false,

		virt_text_pos = "right_align",
		virt_text = config.show_range == true and {
			{ string.format("[ %d,%d ] - [ %d,%d ]", range[1], range[2], range[3], range[4]), utils.set_hl(config.range_hl) }
		} or nil,

		line_hl_group = utils.set_hl(config.text_hl or config.hl),
		hl_mode = "combine"
	});

	---@type integer Window width.
	local win_w = vim.api.nvim_win_get_width(utils.win_findbuf(buffer));
	local tip = spec.get({ item.kind }, {
		source = regex.tips,
		args = { buffer, item },
	});

	if tip and config.show_tip ~= false then
		local lines = utils.to_lines(tip, math.ceil(win_w * 0.8) - (2 * item.level));

		for _, line in ipairs(lines) do
			local r_wh = line:gsub("^%s*", "")

			vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {
				table.concat({
					" ",
					r_wh
				})
			});
		end

		line_count = line_count + #lines;

		if config.tip_hl then
			vim.api.nvim_buf_set_extmark(buffer, regex.ns, vim.api.nvim_buf_line_count(buffer) - line_count + 1, 0, {
				invalidate = true, undo_restore = false,
				end_row = vim.api.nvim_buf_line_count(buffer),

				line_hl_group = utils.set_hl(config.tip_hl),
			});
		end
	end

	local start = vim.api.nvim_buf_line_count(buffer) - line_count;
	local stop = vim.api.nvim_buf_line_count(buffer) - 1;

	for l = start, stop, 1 do
		if l == start then
			vim.api.nvim_buf_set_extmark(buffer, regex.ns, l, 1, {
				invalidate = true, undo_restore = false,

				virt_text_pos = "inline",
				virt_text = {
					{
						string.rep(
							indent_part(),
							item.level
						),
						utils.set_hl(indent_hl)
					}
				},

				hl_mode = "combine"
			});
		else
			vim.api.nvim_buf_set_extmark(buffer, regex.ns, l, 1, {
				invalidate = true, undo_restore = false,

				virt_text_pos = "inline",
				virt_text = {
					{
						table.concat({
							string.rep(
								indent_part(),
								item.level
							),
							indent_marker .. string.rep(" ", (config.tip_offset or 2) - vim.fn.strchars(indent_marker))
						}),
						utils.set_hl(indent_hl)
					},
				},

				hl_mode = "combine"
			});
		end
	end

	return item.current and vim.api.nvim_buf_line_count(buffer) - line_count or nil;
	---|fE
end

regex.render = function (buffer, content)
	vim.api.nvim_buf_clear_namespace(buffer, regex.ns, 0, -1);
	local current_line;

	for _, entry in ipairs(content) do
		local can_render, data = pcall(regex.__generic, buffer, entry);

		if can_render == false then
			-- vim.print(data);
		elseif entry.current then
			current_line = data;
		end
	end

	return current_line;
end

--- Clears decorations from a buffer
---@param buffer integer
---@param from integer?
---@param to integer?
regex.clear = function (buffer, from, to)
	vim.api.nvim_buf_clear_namespace(buffer, regex.ns, from or 0, to or -1);
end

return regex;
