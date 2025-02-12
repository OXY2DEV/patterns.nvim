local parser = {};
local spec = require("patterns.spec");
local utils = require("patterns.utils");

parser.lua_patterns = require("patterns.parsers.lua_patterns");
parser.regex = require("patterns.parsers.regex");

parser.content = {};

parser.parse = function (buffer)
	parser.content = {};

    vim.treesitter.get_parser(buffer):parse(true);
	local root_parser = vim.treesitter.get_parser(buffer);

	root_parser:for_each_tree(function (TSTree, language_tree)
		language_tree:parse(true);

		local language = language_tree:lang();

		if not parser.content[language] then
			parser.content[language] = {};
		end

		if parser[language] then
			vim.print(language)
			parser.content[language] = vim.list_extend(
				parser.content[language],
				parser[language].parse(buffer, TSTree:root())
			);
		end
	end);

	return parser.content;
end

return parser;
