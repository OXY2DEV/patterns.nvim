local regex = {};
local utils = require("patterns.utils");

regex.current = nil;

regex.content = {};
regex.level = 0;

regex.term_id = 0;
regex.capture_id = 0;
regex.non_capture_id = 0;

--- Root node
---@param buffer integer
---@param node table
---@return table | nil
regex.pattern = function (buffer, node)
	if node:parent() then
		--- Do not show this node
		--- when it appears inside another
		--- node.
		regex.level = regex.level - 1;
		return;
	end

	return {
		kind = "pattern",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.alternation = function (buffer, node)
	return {
		kind = "alternation",
		current = node:equal(regex.current),
		id = regex.term_id,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return nil | table
regex.term = function (buffer, node)
	--- This is most likely an internal abstraction
	--- and not a syntax.
	---
	--- Reduce the level of child nodes.

	--- List of parent node types where this node
	--- should be visible.
	---@type string[]
	local possible_parents = { "alternation" };

	if vim.list_contains(possible_parents, node:parent():type()) then
		return {
			kind = "term",
			current = node:equal(regex.current),
			id = regex.term_id,

			text = vim.treesitter.get_node_text(node, buffer),
			range = { node:range() }
		};
	else
		regex.level = regex.level - 1;
	end
end

------------------------------------------------------------------------------

---@param buffer integer
---@param node table
---@return table
regex.start_assertion = function (buffer, node)
	return {
		kind = "start_assertion",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.end_assertion = function (buffer, node)
	return {
		kind = "end_assertion",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.boundary_assertion = function (buffer, node)
	return {
		kind = "boundary_assertion",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.non_boundary_assertion = function (buffer, node)
	return {
		kind = "non_boundary_assertion",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.lookaround_assertion = function (buffer, node)
	return {
		kind = "lookaround_assertion",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

regex.count_quantifier = function (buffer, node)
	return {
		kind = "quantifier_count",
		current = node:equal(regex.current),
		level = regex.level + 1,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

regex.optional = function (buffer, node)
	return {
		kind = "quantifier_optional",
		current = node:equal(regex.current),
		level = regex.level + 1,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

regex.one_or_more = function (buffer, node)
	return {
		kind = "quantifier_plus",
		current = node:equal(regex.current),
		level = regex.level + 1,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

regex.zero_or_more = function (buffer, node)
	return {
		kind = "quantifier_star",
		current = node:equal(regex.current),
		level = regex.level + 1,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

regex.lazy = function (buffer, node)
	return {
		kind = "lazy",
		current = node:equal(regex.current),
		level = regex.level + 1,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

---@param buffer integer
---@param node table
---@return table
regex.pattern_character = function (buffer, node)
	return {
		kind = "pattern_character",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.class_character = function (buffer, node)
	return {
		kind = "class_character",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.any_character = function (buffer, node)
	return {
		kind = "any_character",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.decimal_escape = function (buffer, node)
	return {
		kind = "decimal_escape",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.character_class_escape = function (buffer, node)
	return {
		kind = "character_class_escape",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.unicode_property_value = function (buffer, node)
	return {
		kind = "unicode_property_value",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.unicode_character_escape = function (buffer, node)
	return {
		kind = "unicode_character_escape",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.control_escape = function (buffer, node)
	return {
		kind = "control_escape",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.control_letter_escape = function (buffer, node)
	return {
		kind = "control_letter_escape",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.identity_escape = function (buffer, node)
	return {
		kind = "identity_escape",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.backreference_escape = function (buffer, node)
	return {
		kind = "backreference_escape",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

---@param buffer integer
---@param node table
---@return table
regex.unicode_property_value_expression = function (buffer, node)
	return {
		kind = "unicode_property_value_expression",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

---@param buffer integer
---@param node table
---@return table
regex.character_class = function (buffer, node)
	return {
		kind = "character_class",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.posix_character_class = function (buffer, node)
	return {
		kind = "posix_character_class",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.named_group_backreference = function (buffer, node)
	return {
		kind = "named_group_backreference",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

---@param buffer integer
---@param node table
---@return table
regex.anonymous_capturing_group = function (buffer, node)
	regex.capture_id = regex.capture_id + 1;

	return {
		kind = "capturing_group",
		current = node:equal(regex.current),
		id = regex.capture_id,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.named_capturing_group = function (buffer, node)
	---@type string
	local text = vim.treesitter.get_node_text(node, buffer);
	local ID = string.match(text, "^%(%?P?%<(.-)%>.*%)")

	return {
		kind = "capturing_group",
		current = node:equal(regex.current),
		id = ID,

		text = text,
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.non_capturing_group = function (buffer, node)
	regex.non_capture_id = regex.non_capture_id + 1;

	return {
		kind = "non_capturing_group",
		current = node:equal(regex.current),
		id = regex.non_capture_id,

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.inline_flags_group = function (buffer, node)
	return {
		kind = "flags_group",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

---@param buffer integer
---@param node table
---@return table
regex.flags = function (buffer, node)
	return {
		kind = "flags",
		current = node:equal(regex.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

regex.traverse = function (buffer, node)
	regex.level = regex.level + 1;

	for child in node:iter_children() do
		local kind = child:type();
		local could_parse, data = pcall(regex[kind], buffer, child);

		if could_parse == false then
			--- Do stuff
		elseif type(data) == "table" then
			data.level = data.level or regex.level;
			table.insert(regex.content, data);
		end

		regex.traverse(buffer, child)
	end

	regex.level = regex.level - 1;
end

regex.parse = function (buffer, root)
	regex.content = {};
	regex.level = 0;

	regex.term_id = 0;
	regex.capture_id = 0;
	regex.non_capture_id = 0;

	---@type string Root node type.
	local type = root:type();
	local win = utils.win_findbuf(buffer);

	vim.api.nvim_win_call(win, function ()
		regex.current = vim.treesitter.get_node({
			buffer = buffer
		});
	end)

	---|fS "We must try to parse the root node first"
	local could_parse, data = pcall(regex[type], buffer, root);

	if could_parse == false then
		-- vim.print(data)
		--- Do error
	else
		data.level = data.level or regex.level;
		table.insert(regex.content, data);
	end

	---|fE

	regex.traverse(buffer, root);
	return regex.content;
end

return regex;
