--- Register parsers to custom filetypes.
vim.treesitter.language.register("lua_patterns", "LuaPatterns");
vim.treesitter.language.register("regex", "RegexPatterns");

--- Sets up the highlight groups.
--- Should be called AFTER loading
--- colorschemes.
vim.api.nvim_create_autocmd({
	"VimEnter",
	"ColorScheme"
}, {
	callback = function ()
		local hls = require("patterns.highlights");
		hls.create(hls.groups);
	end
});

--- User command.
vim.api.nvim_create_user_command("Patterns", function (cmd)
	local patterns = require("patterns");

	---@type string[]
	local args = cmd.fargs;

	if patterns.actions[args[1]] then
		patterns.actions[args[1]]();
	else
		patterns.actions.explain();
	end
end, {
	desc = "Command for patterns.mvim",
	nargs = "?",

	complete = function (arg_lead)
		local _c = {};

		for _, item in ipairs({ "explain", "hover" }) do
			if item:match(arg_lead) then
				table.insert(_c, item);
			end
		end

		table.sort(_c);
		return _c;
	end
});
