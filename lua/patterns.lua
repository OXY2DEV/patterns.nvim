local patterns = {};
local spec = require("patterns.spec");

patterns.preview_buf = nil;
patterns.preview_win = nil;

patterns.input_buf = nil;
patterns.input_win = nil;

patterns.au = vim.api.nvim_create_augroup("patterns", { clear = true });

patterns.viewer_setup = function ()
	patterns.au = vim.api.nvim_create_augroup("patterns", { clear = true });

	if type(patterns.input_buf) ~= "number" or vim.api.nvim_buf_is_valid(patterns.input_buf) == false then
		patterns.input_buf = vim.api.nvim_create_buf(false, true);
	end

	---@type table
	local input = spec.get({ "windows", "input" }, {
		fallback = {},
		args = {
			patterns.input_buf or -1, patterns.input_win or -1, patterns.preview_buf or -1, patterns.preview_win or -1
		}
	});

	if type(patterns.input_win) ~= "number" or vim.api.nvim_win_is_valid(patterns.input_win) == false then
		patterns.input_win = vim.api.nvim_open_win(patterns.input_buf, true, vim.tbl_deep_extend(
			"force",
			{
				title = "Input"
			},
			input
		));
	else
		vim.api.nvim_win_set_config(patterns.input_win, vim.tbl_deep_extend(
			"force",
			{
				title = "Input"
			},
			input
		));
	end

	if type(patterns.preview_buf) ~= "number" or vim.api.nvim_buf_is_valid(patterns.preview_buf) == false then
		patterns.preview_buf = vim.api.nvim_create_buf(false, true);
	end

	---@type table
	local preview = spec.get({ "windows", "preview" }, {
		fallback = {},
		args = { patterns.input_buf, patterns.input_win, patterns.preview_buf, patterns.preview_win }
	});

	if type(patterns.preview_win) ~= "number" or vim.api.nvim_win_is_valid(patterns.preview_win) == false then
		patterns.preview_win = vim.api.nvim_open_win(patterns.preview_buf, false, preview)
	else
		vim.api.nvim_win_set_config(patterns.preview_win, preview);
	end

	vim.wo[patterns.preview_win].cursorline = false;
	vim.wo[patterns.preview_win].scrolloff = math.floor(preview.height / 2);

	vim.api.nvim_create_autocmd( "VimResized", {
		group = patterns.au,
		callback = function ()
			patterns.viewer_setup();
		end
	});

	vim.api.nvim_create_autocmd({
		"WinClosed"
	}, {
		pattern = { tostring(patterns.input_win), tostring(patterns.preview_win) },

		callback = function ()
			patterns.viewer_close();
		end
	});

	-- vim.api.nvim_create_autocmd({
	-- 	"BufEnter"
	-- }, {
	-- 	group = patterns.au,
	--
	-- 	callback = function (event)
	-- 		local buf = tonumber(event.buf);
	--
	-- 		if (patterns.preview_win and patterns.input_win) and buf ~= patterns.preview_buf and buf ~= patterns.input_buf then
	-- 			patterns.viewer_close();
	-- 		end
	-- 	end
	-- });
end

patterns.render = function ()
	---@type { [string]: table[] } The parsed content.
	local content = require("patterns.parser").parse(patterns.input_buf);

	vim.api.nvim_buf_set_lines(patterns.preview_buf, 0, -1, false, {});
	require("patterns.renderer").render(patterns.preview_buf, content);
end

patterns.viewer_close = function ()
	patterns.au = vim.api.nvim_create_augroup("patterns", { clear = true });

	pcall(vim.api.nvim_win_close, patterns.preview_win, true);
	pcall(vim.api.nvim_win_close, patterns.input_win, true);
end


patterns.actions = {
	open = function ()
		patterns.viewer_setup();
		vim.bo[patterns.input_buf].ft = "LuaPatterns";

		patterns.render();
		patterns.viewer_setup();

		vim.api.nvim_buf_set_keymap(patterns.input_buf, "i", "<Tab>", "", {
			callback = function ()
				if vim.bo[patterns.input_buf].ft == "LuaPatterns" then
					vim.bo[patterns.input_buf].ft = "RegexPatterns";
				else
					vim.bo[patterns.input_buf].ft = "LuaPatterns";
				end

				patterns.render();
				patterns.viewer_setup();
			end
		});

		local typer = vim.uv.new_timer();

		vim.api.nvim_create_autocmd({
			"TextChanged", "TextChangedI",
			"CursorMoved", "CursorMovedI"
		}, {
			buffer = patterns.input_buf,

			callback = function ()
				typer:stop();
				typer:start(100, 0, vim.schedule_wrap(function ()
					patterns.render();
					patterns.viewer_setup();
				end))
			end
		});
	end,




	analyze = function ()
		---@type integer
		local buffer = vim.api.nvim_get_current_buf();

		local can_get_node, node = pcall(vim.treesitter.get_node, {
			language = "lua",
			ignore_injections = true
		});

		if can_get_node == false then
			return;
		elseif node:type() ~= "string_content" then
			return;
		end

		local window = vim.api.nvim_get_current_win();
		local cursor = vim.api.nvim_win_get_cursor(window);

		-- patterns.ui:open(
		-- 	vim.split(
		-- 		vim.treesitter.get_node_text(node, buffer),
		-- 		"\n",
		-- 		{ trimempty = true }
		-- 	)
		-- );

		local range = { node:range() };

		pcall(vim.api.nvim_win_set_cursor, patterns.ui.input_win, {
			cursor[1] - range[1],
			cursor[2] - range[2]
		});
	end
};

patterns.setup = function (user_config)
end

return patterns;
