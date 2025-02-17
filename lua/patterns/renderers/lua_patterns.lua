local lua_patterns = {};

local spec = require("patterns.spec");
local utils = require("patterns.utils");

lua_patterns.ns = vim.api.nvim_create_namespace("patterns/lua_patterns");

lua_patterns.tips = {
	anchor_start = "Only match if the pattern is at the beginning of the string.",
	anchor_end = "Only match if the pattern is at the end of the string.",

	quantifier_minus = "Matches a pattern zero or more times.\n \n This will match the lowest number of repeats.",
	quantifier_optional = "Matches a pattern zero or one time.",
	quantifier_plus = "Matches a pattern one or more times.\n \n This will match the highest number of repeats.",
	quantifier_star = "Matches a pattern zero or more times.\n \n This will match the highest number of repeats.",

	character = function (_, item)
		return string.format("Matches %s literally.", vim.inspect(item.text));
	end,
	any = "Matches any character.",
	escaped_character = function (_, item)
		local _l = {
			"A character that was escaped.",
			"",
			"",
			"Escaping is typically done to match magic characters(e.g. ^, $) literally."
		};
		local char = string.match(item.text, "^%%(.)$");

		if string.match(char, "[%.%^%$%+%-%*%?%%%[%]%(%)]") then
			table.insert(_l, 3, string.format("✔ %s is a magic character.", vim.inspect(char)));
		else
			table.insert(_l, 3, string.format("✘ %s isn't a magic character!", vim.inspect(char)));
			table.insert(_l, string.format("As %s isn't a magic character there's no need to escape it.", vim.inspect(char)));
		end

		return table.concat(_l, "\n");
	end,
	escape_sequence = function (_, item)
		local seq_maps = {
			["\\b"]  = "󰌥 This one represents a backspace.",
			-- ["\\f"]  = "󰌥 This one represents a backspace.",
			["\\n"]  = "󰌑 This one represents a newlinw.",
			["\\t"]  = "󰌒 This one represents a tab.",
			["\\r"]  = "󰌏 This one represents a return carriage.",
			-- ["\\v"]  = "󰌥 This one represents a backspace.",
			["\\0"]  = "󰋷 This one represents a null byte.",
			["\\\\"] = '󰓾 This one represents a "\\".',
			["\\'"]  = ' This one represents a "\'".',
			['\\"']  = " This one represents a '\"'.",

			default = "This one matches " .. item.text .. "."
		}
		return table.concat({
			"An escape sequence.",
			"",
			seq_maps[item.text] or seq_maps.default
		}, "\n");
	end,

	character_set = "Matches characters from a set of matches.",
	-- character_set_content = "Set of matches.",
	capture_group = "A pattern group to be used for various string operations.",
	character_range = "Matches character within the given range.",
	character_class = function (_, item)
		local txt = item.text;
		local _l = { "Matches a class of characters.", "" };

		if txt == "%a" then
			table.insert(_l, '"%a" matches all letters. It\'s equivalent would be: [a-zA-Z].');
		elseif txt == "%A" then
			table.insert(_l, '"%A" matches anything that\'s not a letter. It\'s equivalent would be: [^a-zA-Z].');
		elseif txt == "%c" then
			-- table.insert(_l, '"%c" matches all control characters. It\'s equivalent would be: [^a-zA-Z].');
		elseif txt == "%C" then
			-- table.insert(_l, '"%C" matches anything that\'s not a control character. It\'s equivalent would be: [^a-zA-Z].');
		elseif txt == "%d" then
			table.insert(_l, '"%d" matches all digits. It\'s equivalent would be: [0-9].');
		elseif txt == "%D" then
			table.insert(_l, '"%D" matches anything that\'s not a digit. It\'s equivalent would be: [^0-9].');
		elseif txt == "%l" then
			table.insert(_l, '"%l" matches all lowercase letters. It\'s equivalent would be: [a-z].');
		elseif txt == "%L" then
			table.insert(_l, '"%L" matches anything that\'s not a lowercase letter. It\'s equivalent would be: [^a-z].');
		elseif txt == "%p" then
			table.insert(_l, '"%p" matches all punctuation symbols. It\'s equivalent would be: [a-z].');
		elseif txt == "%P" then
			table.insert(_l, '"%P" matches anything that\'s not a punctuation symbol. It\'s equivalent would be: [^a-z].');
		elseif txt == "%s" then
			table.insert(_l, '"%p" matches all whitespace characters. It\'s equivalent would be: [ \\t\\n\\r].');
		elseif txt == "%S" then
			table.insert(_l, '"%P" matches anything that\'s not a punctuation symbol. It\'s equivalent would be: [^ \\t\\n\\r].');
		elseif txt == "%u" then
			table.insert(_l, '"%u" matches all uppercase letters. It\'s equivalent would be: [A-Z].');
		elseif txt == "%U" then
			table.insert(_l, '"%U" matches anything that\'s not a uppercase letter. It\'s equivalent would be: [^A-Z].');
		elseif txt == "%w" then
			-- table.insert(_l, '"%w" matches all alphanumeric characters. It\'s equivalent would be: [^a-zA-Z].');
		elseif txt == "%W" then
			-- table.insert(_l, '"%W" matches anything that\'s not an alphanumeric character. It\'s equivalent would be: [^a-zA-Z].');
		elseif txt == "%x" then
			table.insert(_l, '"%x" matches all hexadecimal characters. It\'s equivalent would be: [a-fA-F0-9].');
		elseif txt == "%X" then
			table.insert(_l, '"%X" matches anything that\'s not an hexadecimal character. It\'s equivalent would be: [^a-fA-F0-9].');
		elseif txt == "%z" then
			table.insert(_l, '"%x" matches the null byte. It\'s equivalent would be: [\\0].');
		elseif txt == "%Z" then
			table.insert(_l, '"%Z" matches anything that\'s not a null byte. It\'s equivalent would be: [^\\0].');
		else
			table.remove(_l, 2);
		end

		return table.concat(_l, "\n");
	end,
}

lua_patterns.__generic = function (buffer, item)
	---|fS

	---@type integer[] { row_start, col_start, row_end, col_end }
	local range = item.range;

	---@type integer Indent size
	local indent = spec.get({ "lua_patterns", "indent_size" }, {
		fallback = 2,
		eval_args = { buffer, item }
	});
	---@type string Indent
	local indent_marker = spec.get({ "lua_patterns", "indent_marker" }, {
		fallback = " ",
		eval_args = { buffer, item }
	});
	---@type string? Indent hl
	local indent_hl = spec.get({ "lua_patterns", "indent_hl" }, {
		fallback = nil,
		eval_args = { buffer, item }
	});

	---@type pattern_item.opts Config table.
	local config = spec.get({ "lua_patterns", item.kind }, {
		fallback = {},
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

	vim.api.nvim_buf_set_extmark(buffer, lua_patterns.ns, vim.api.nvim_buf_line_count(buffer) - line_count, 0, {
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
		source = lua_patterns.tips,
		eval_args = { buffer, item}
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
			vim.api.nvim_buf_set_extmark(buffer, lua_patterns.ns, vim.api.nvim_buf_line_count(buffer) - line_count + 1, 0, {
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
			vim.api.nvim_buf_set_extmark(buffer, lua_patterns.ns, l, 1, {
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
			vim.api.nvim_buf_set_extmark(buffer, lua_patterns.ns, l, 1, {
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

lua_patterns.render = function (buffer, content)
	vim.api.nvim_buf_clear_namespace(buffer, lua_patterns.ns, 0, -1);
	local current_line;

	for _, entry in ipairs(content) do
		local can_render, data = pcall(lua_patterns.__generic, buffer, entry);

		if can_render == false then
			vim.print(data)
		elseif entry.current then
			current_line = data;
		end
	end

	return current_line;
end

lua_patterns.clear = function (buffer, from, to)
	vim.api.nvim_buf_clear_namespace(buffer, lua_patterns.ns, from or 0, to or -1);
end

return lua_patterns;
