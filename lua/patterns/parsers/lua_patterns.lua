local lua_patterns = {};
local utils = require("patterns.utils");

lua_patterns.current = nil;

lua_patterns.content = {};
lua_patterns.level = 0;

lua_patterns.capture_id = 0;

------------------------------------------------------------------------------

lua_patterns.pattern = function (buffer, node)
	return {
		kind = "pattern",

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

lua_patterns.start_assertion = function (buffer, node)
	return {
		kind = "anchor_start",
		current = node:equal(lua_patterns.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

lua_patterns.end_assertion = function (buffer, node)
	return {
		kind = "anchor_end",
		current = node:equal(lua_patterns.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

lua_patterns.lazy = function (buffer, node)
	return {
		kind = "quantifier_minus",
		current = node:equal(lua_patterns.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

lua_patterns.optional = function (buffer, node)
	return {
		kind = "quantifier_optional",
		current = node:equal(lua_patterns.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

lua_patterns.one_or_more = function (buffer, node)
	return {
		kind = "quantifier_plus",
		current = node:equal(lua_patterns.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

lua_patterns.zero_or_more = function (buffer, node)
	return {
		kind = "quantifier_star",
		current = node:equal(lua_patterns.current),

		text = vim.treesitter.get_node_text(node, buffer),
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

lua_patterns.character_set = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	return {
		kind = "character_set",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.character_set_content = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	return {
		kind = "character_set_content",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.character_range = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	return {
		kind = "character_range",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.character_class = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	return {
		kind = "character_class",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.capture_group = function (buffer, node)
	lua_patterns.capture_id = lua_patterns.capture_id + 1;
	local text = vim.treesitter.get_node_text(node, buffer);

	return {
		kind = "capture_group",
		id = lua_patterns.capture_id,
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

lua_patterns.any = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	--- Remove quantifiers.
	if text:match("[^%%][%+%-%*%?]$") then
		text = text:gsub("[%+%-%*%?]$", "");
	end

	return {
		kind = "any",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.class_pattern = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	--- Remove quantifiers.
	if text:match("[^%%][%+%-%*%?]$") then
		text = text:gsub("[%+%-%*%?]$", "");
	end

	return {
		kind = "class",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.trail_character = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	if text:match("[^%%][%+%-%*%?]$") then
		text = text:gsub("[%+%-%*%?]$", "");
	end

	return {
		kind = "trialing_character",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.literal_character = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	if node:parent():type() == "pattern" and node:next_sibling() == nil then
		lua_patterns.trail_character(buffer, node)
		return;
	elseif text:match("[^%%][%+%-%*%?]$") then
		text = text:gsub("[%+%-%*%?]$", "");
	end

	text = vim.inspect(text):gsub('^%"\n', "");

	return {
		kind = "character",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.escaped_character = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	if text:match("[^%%][%+%-%*%?]$") then
		text = text:gsub("[%+%-%*%?]$", "");
	elseif text:match("^%%$") then
		return;
	end

	text = vim.inspect(text):gsub('^%"\n', "");

	return {
		kind = "escaped_character",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

lua_patterns.escape_sequence = function (buffer, node)
	local text = vim.treesitter.get_node_text(node, buffer);

	if text:match("[^%%][%+%-%*%?]$") then
		text = text:gsub("[%+%-%*%?]$", "");
	end

	return {
		kind = "escape_sequence",
		current = node:equal(lua_patterns.current),

		text = text,
		range = { node:range() }
	};
end

------------------------------------------------------------------------------

lua_patterns.traverse = function (buffer, node)
	lua_patterns.level = lua_patterns.level + 1;

	for child in node:iter_children() do
		local kind = child:type();
		local could_parse, data = pcall(lua_patterns[kind], buffer, child);

		if could_parse == false then
			--- Do stuff
		elseif type(data) == "table" then
			data.level = lua_patterns.level;
			table.insert(lua_patterns.content, data);
		end

		lua_patterns.traverse(buffer, child)
	end

	lua_patterns.level = lua_patterns.level - 1;
end

lua_patterns.parse = function (buffer, root)
	lua_patterns.content = {};
	lua_patterns.level = 0;

	lua_patterns.capture_id = 0;

	---@type string Root node type.
	local type = root:type();
	local win = utils.win_findbuf(buffer);

	vim.api.nvim_win_call(win, function ()
		lua_patterns.current = vim.treesitter.get_node({
			buffer = buffer
		});
	end)

	---|fS "We must try to parse the root node first"
	local could_parse, data = pcall(lua_patterns[type], buffer, root);

	if could_parse == false then
		-- vim.print(data)
		--- Do error
	else
		data.level = lua_patterns.level;
		table.insert(lua_patterns.content, data);
	end

	---|fE

	lua_patterns.traverse(buffer, root);
	return lua_patterns.content;
end

return lua_patterns;
