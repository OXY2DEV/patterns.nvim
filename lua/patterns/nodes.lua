local node = {};

node.angular = node.html_tags;

node.astro = node.html_tags;

node.awk = {
	RegexPatterns = { "regex" },
};

node.bash = {
	RegexPatterns = { "regex" },
};

node.bitbake = {
	RegexPatterns = { "string_content" },
};

node.ecma = {
	RegexPatterns = { "regex_pattern" },
};

node.elixir = {
	RegexPatterns = { "quoted_content" },
};

node.fennel = {
	LuaPatterns = { "string_content" },
};

node.foam = {
	RegexPatterns = { "string_literal" },
};

node.glimmer_javascript = node.ecma;

node.glimmer_typescript = node.ecma;

node.go = {
	RegexPatterns = { "raw_string_literal_content", "interpreted_string_literal_content" },
};

node.hare = {
	RegexPatterns = { "string_content", "raw_string_content" },
};

node.helm = {
	RegexPatterns = { "interpreted_string_literal" },
};

node.html_tags = {
	RegexPatterns = { "attribute_value" },
};

node.javascript = node.ecma;

node.jq = {
	RegexPatterns = { "string" },
};

node.julia = {
	RegexPatterns = { "string" },
};

node.just = {
	RegexPatterns = { "string" },
};

node.kotlin = {
	RegexPatterns = { "string_literal" },
};

node.lalrpop = {
	RegexPatterns = { "regex_literal" },
};

node.lua = {
	LuaPatterns = { "string_content" },
};

node.luau = {
	LuaPatterns = { "string" },
};

node.muttrc = {
	RegexPatterns = { "regex" },
};

node.nim = {
	RegexPatterns = { "string_content" },
};

node.nix = {
	RegexPatterns = { "string_fragment" },
};

node.php_only = {
	RegexPatterns = { "string_content" },
};

node.php = node.php_only;

node.powershell = {
	RegexPatterns = { "string_literal" },
};

node.promql = {
	RegexPatterns = { "label_value" },
};

node.puppet = {
	RegexPatterns = { "regex" },
};

node.python = {
	RegexPatterns = { "string_content" },
};

node.qmljs = node.ecma;

node.query = {
	RegexPatterns = { "string_content" },
	LuaPatterns = { "string_content" },
};

node.rescript = {
	RegexPatterns = { "expression_statement" },
};

node.ruby = {
	RegexPatterns = { "string_content" },
};

node.rust = {
	RegexPatterns = { "string_content" },
};

node.snakemake = {
	RegexPatterns = { "constraint" },
};

node.templ = node.go;

node.tsx = node.ecma;

node.typescript = node.ecma;

node.v = {
	RegexPatterns = { "raw_string_literal" },
};

node.vim = {
	RegexPatterns = { "pattern" },
};

node.vrl = {
	RegexPatterns = { "regex" },
};

node.wing = {
	RegexPatterns = { "string" },
};

node.yang = {
	RegexPatterns = { "string" },
};

node.yuck = {
	RegexPatterns = { "string_fragment" },
};

--- Gets the pattern filetype.
---@param language string
---@param node_type string
---@return string | nil
node.get_ft = function (language, node_type)
	local map = node[language] or {};

	for lang, node_types in pairs(map) do
		if vim.list_contains(node_types, node_type) then
			return lang;
		end
	end
end

return node;
