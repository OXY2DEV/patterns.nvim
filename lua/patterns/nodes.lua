local node = {};

node.angular = node.html_tags;

node.astro = node.html_tags;

node.awk = {
	regex = { "regex" },
};

node.bash = {
	regex = { "regex" },
};

node.bitbake = {
	regex = { "string_content" },
};

node.ecma = {
	regex = { "regex_pattern" },
};

node.elixir = {
	regex = { "quoted_content" },
};

node.fennel = {
	lua_patterns = { "string_content" },
};

node.foam = {
	regex = { "string_literal" },
};

node.glimmer_javascript = node.ecma;

node.glimmer_typescript = node.ecma;

node.go = {
	regex = { "raw_string_literal_content", "interpreted_string_literal_content" },
};

node.hare = {
	regex = { "string_content", "raw_string_content" },
};

node.helm = {
	regex = { "interpreted_string_literal" },
};

node.html_tags = {
	regex = { "attribute_value" },
};

node.javascript = node.ecma;

node.jq = {
	regex = { "string" },
};

node.julia = {
	regex = { "string" },
};

node.just = {
	regex = { "string" },
};

node.kotlin = {
	regex = { "string_literal" },
};

node.lalrpop = {
	regex = { "regex_literal" },
};

node.lua = {
	lua_patterns = { "string_content" },
};

node.luau = {
	lua_patterns = { "string" },
};

node.muttrc = {
	regex = { "regex" },
};

node.nim = {
	regex = { "string_content" },
};

node.nix = {
	regex = { "string_fragment" },
};

node.php_only = {
	regex = { "string_content" },
};

node.php = node.php_only;

node.powershell = {
	regex = { "string_literal" },
};

node.promql = {
	regex = { "label_value" },
};

node.puppet = {
	regex = { "regex" },
};

node.python = {
	regex = { "string_content" },
};

node.qmljs = node.ecma;

node.query = {
	regex = { "string_content" },
	lua_patterns = { "string_content" },
};

node.rescript = {
	regex = { "expression_statement" },
};

node.ruby = {
	regex = { "string_content" },
};

node.rust = {
	regex = { "string_content" },
};

node.snakemake = {
	regex = { "constraint" },
};

node.templ = node.go;

node.tsx = node.ecma;

node.typescript = node.ecma;

node.v = {
	regex = { "raw_string_literal" },
};

node.vim = {
	regex = { "pattern" },
};

node.vrl = {
	regex = { "regex" },
};

node.wing = {
	regex = { "string" },
};

node.yang = {
	regex = { "string" },
};

node.yuck = {
	regex = { "string_fragment" },
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
