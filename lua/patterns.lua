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
		---|fS

		hover.hover();

		---|fE
	end,

	explain = function ()
		local ft, lines, range = utils.create_pattern_range(true);

		if not ft or not lines or not range then
			explain.explain();
			return;
		end

		local r_map = {
			LuaPatterns = "lua_patterns",
			RegexPatterns = "regex"
		}

		explain.explain(r_map[ft] or "lua_patterns", lines, range);
	end
};

patterns.setup = function (user_config)
end

return patterns;
