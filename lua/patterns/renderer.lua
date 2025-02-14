local renderer = {};

renderer.lua_patterns = require("patterns.renderers.lua_patterns");
renderer.regex = require("patterns.renderers.regex");

renderer.render = function (buffer, content)
	local current_line;

	for k, v in pairs(content) do
		if renderer[k] then
			current_line = renderer[k].render(buffer, v);
		end
	end

	vim.api.nvim_buf_set_lines(buffer, 0, 1, false, {});
	return current_line;
end

return renderer;
