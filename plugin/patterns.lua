vim.treesitter.language.register("lua_patterns", "LuaPatterns");
vim.treesitter.language.register("regex", "RegexPatterns");

--- Sets up the highlight groups.
--- Should be called AFTER loading
--- colorschemes.
require("patterns.highlights").setup();

--- Updates the highlight groups.
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function ()
		local hls = require("patterns.highlights");
		hls.create(hls.groups);
	end
});

vim.api.nvim_create_user_command("Pat", function ()
	require("patterns").actions.explain("lua_patterns", { "hi" });
end, {})
