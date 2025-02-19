local patterns = {};

local spec = require("patterns.spec");
local utils = require("patterns.utils");

local hover = require("patterns.hover");
local explain = require("patterns.explain");

--- Renders stuff to the preview buffer
patterns.render = function (src_buf, prev_buf)
	---@type { [string]: table[] } The parsed content.
	local content = require("patterns.parser").parse(src_buf);

	vim.bo[prev_buf].modifiable = true;

	vim.api.nvim_buf_set_lines(prev_buf, 0, -1, false, {});
	return require("patterns.renderer").render(prev_buf, content);
end

--- Renders stuff to the preview buffer
patterns.clear = function (prev_buf)
	vim.bo[prev_buf].modifiable = true;

	vim.api.nvim_buf_set_lines(prev_buf, 0, -1, false, {});
	return require("patterns.renderer").clear(prev_buf);
end

patterns.actions = {
	hover = function ()
		local available_parsers = { "lua_patterns", "regex" };

		available_parsers = vim.tbl_filter(function (parser)
			return utils.parser_installed(parser);
		end, available_parsers);

		if #available_parsers == 0 then
			vim.api.nvim_echo({
				{ " 󰑑 patterns.nvim ", "DiagnosticVirtualTextInfo" },
				{ ": ", "Comment" },
				{ "Looks like you don't have the necessary parsers installed! See README.", "Comment" },
			}, true, {})
			return;
		else
			hover.hover();
		end
	end,

	explain = function ()
		local ft, lines, range = utils.create_pattern_range(true);

		local available_parsers = { "lua_patterns", "regex" };

		available_parsers = vim.tbl_filter(function (parser)
			return utils.parser_installed(parser);
		end, available_parsers);

		if #available_parsers == 0 then
			vim.api.nvim_echo({
				{ " 󰑑 patterns.nvim ", "DiagnosticVirtualTextInfo" },
				{ ": ", "Comment" },
				{ "Looks like you don't have the necessary parsers installed! See README.", "Comment" },
			}, true, {})
			return;
		elseif vim.list_contains(available_parsers, ft) == false then
			explain.explain(available_parsers[1], lines, range);
		else
			explain.explain(ft, lines, range);
		end
	end
};

--- Main setup function.
---@param user_config patterns.config | nil
patterns.setup = function (user_config)
	spec.setup(user_config);
end

return patterns;
