---@alias patterns.hl
---| vim.api.keyset.highlight Literal highlight definition.
---| fun(): vim.api.keyset.highlight Dynamically created literal highlight definition.
---| fun(): patterns.hl.value[] List of tables to create highlights from.

---@class patterns.hl.value
---
---@field group_name string
---@field value vim.api.keyset.highlight

---@class patterns.hl.rgb
---
---@field r integer
---@field g integer
---@field b integer

---@class patterns.hl.Lab
---
---@field L integer
---@field a integer
---@field b integer


--[[
*Dynamic* highlights for `patterns.nvim` to match the current `colorscheme`.

Usage,

```lua
require("patterns.highlights").setup();
```
]]
local highlights = {};

--- Clamps a value between 0 & 255.
---@param c integer
---@return integer
local function clamp (c)
	return math.min(
		math.max(
			0,
			math.floor(c)
		),
		255
	);
end

--[[ Turns given color into **RGB** color value. ]]
---@param input string | number
---@return patterns.hl.rgb
---@return boolean invalid_value Was the given value invalid?
highlights.rgb = function (input)
	---|fS

	local lookup = vim.api.nvim_get_color_map();
	local hex;

	if type(input) == "string" and (lookup[input]) then
		hex = string.format("#%06x", lookup[input]);
	elseif type(input) == "number" then
		hex = string.format("#%06x", input);
	else
		hex = type(input) == "string" and input or "#FFFFFF";
	end

	return {
		r = tonumber(
			string.sub(hex, 2, 3),
			16
		),
		g = tonumber(
			string.sub(hex, 4, 5),
			16
		),
		b = tonumber(
			string.sub(hex, 6, 7),
			16
		),
	}, type(input) ~= "string" and type(input) ~= "number";

	---|fE
end

--[[ Simple RGB color mixer. ]]
---@param c1 patterns.hl.rgb | patterns.hl.Lab
---@param c2 patterns.hl.rgb | patterns.hl.Lab
---@param p1 number
---@param p2 number
---@return patterns.hl.rgb | patterns.hl.Lab
highlights.mix = function (c1, c2, p1, p2)
	---|fS

	local out = {};

	for k, v in pairs(c1) do
		if c2[k] then
			out[k] = (v * p1) + (c2[k] * p2);
		else
			out[k] = v;
		end
	end

	return out;

	---|fE
end

--[[ `RGB` to `hex color code` converter. ]]
---@param color patterns.hl.rgb
---@return string
highlights.rgb_to_hex = function (color)
	return string.format(
		"#%02x%02x%02x",
		clamp(color.r),
		clamp(color.g),
		clamp(color.b)
	)
end

---|fS "chunk: sRGB <-> Oklab"

--[[
`sRGB` -> `Oklab` conversion.

Source: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
License: https://bottosson.github.io/misc/License.txt
]]
---@param c patterns.hl.rgb
---@return patterns.hl.Lab
highlights.srgb_to_oklab = function (c)
    local l = 0.4122214708 * c.r + 0.5363325363 * c.g + 0.0514459929 * c.b;
	local m = 0.2119034982 * c.r + 0.6806995451 * c.g + 0.1073969566 * c.b;
	local s = 0.0883024619 * c.r + 0.2817188376 * c.g + 0.6299787005 * c.b;

    local l_ = math.pow(l, 1 / 3);
    local m_ = math.pow(m, 1 / 3);
    local s_ = math.pow(s, 1 / 3);

    return {
        L = 0.2104542553 *l_ + 0.7936177850 *m_ - 0.0040720468 *s_,
        a = 1.9779984951 *l_ - 2.4285922050 *m_ + 0.4505937099 *s_,
        b = 0.0259040371 *l_ + 0.7827717662 *m_ - 0.8086757660 *s_,
    };
end


--[[
`Oklab` -> `sRGB` conversion.

Source: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
License: https://bottosson.github.io/misc/License.txt
]]
highlights.oklab_to_srgb = function (c)
    local l_ = c.L + 0.3963377774 * c.a + 0.2158037573 * c.b;
    local m_ = c.L - 0.1055613458 * c.a - 0.0638541728 * c.b;
    local s_ = c.L - 0.0894841775 * c.a - 1.2914855480 * c.b;

    local l = l_*l_*l_;
    local m = m_*m_*m_;
    local s = s_*s_*s_;

    return {
		r = clamp( 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
		g = clamp(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
		b = clamp(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s),
    };
end

---|fE

--- Wrapper function for `nvim_set_hl()`.
---@param name string
---@param value table
highlights.set_hl = function (name, value)
	---|fS

	local found, v = pcall(vim.api.nvim_get_hl, 0, { name = name, create = false, link = false });
	local is_empty = vim.deep_equal(v, vim.empty_dict());

	if found and not is_empty then
		-- ISSUE: Old highlight group values are stored as `vim.empty_dict()`. These should be overwritten.
		-- BUG(no-regression): No way to remove any of patterns's highlight group entirely.
		return;
	end

	-- NOTE: `default = true` will skip empty highlight groups.
	value.default = not is_empty;
	local success, err = pcall(vim.api.nvim_set_hl, 0, name, value);

	if success == false and err then
		require("patterns.health").print({
			kind = "hl",

			from = "highlights.lua",
			fn = "set_hl() -> " .. tostring(name),

			name = name,
			value = value,
			message = {
				{ tostring(err), "DiagnosticError" }
			}
		});
	end

	---|fE
end

--- Creates highlight groups from an array of tables
---@param array table<string, patterns.hl>
highlights.create = function (array)
	---|fS

	if type(array) == "string" then
		if not highlights[array] then
			return;
		end

		array = highlights[array];
	end

	local hls = vim.tbl_keys(array) or {};
	table.sort(hls);

	for _, hl in ipairs(hls) do
		local _value = array[hl];
		local value;

		if type(_value) == "function" then
			local s, v = pcall(_value);

			if s then
				value = v;
			else
				value = {};
			end
		else
			value = _value;
		end

		if not hl:match("^Patterns") then
			hl = "Patterns" .. hl;
		end

		if vim.islist(value) and #value > 0 then
			---@cast value table[]
			for _, entry in ipairs(value) do
				highlights.set_hl(entry.group_name, entry.value);
			end
		elseif type(value) == "table" then
			---@cast value table
			highlights.set_hl(hl, value);
		end
	end

	---|fE
end

--- Is the background "dark"?
--- Returns values based on this condition(when provided).
---@param on_light any
---@param on_dark any
---@return any
local is_dark = function (on_light, on_dark)
	return vim.o.background == "dark" and on_dark or on_light;
end

--[[ Gets `property` from a list of `highlight group`s. ]]
---@param property string
---@param groups string[]
---@param light any
---@param dark any
---@return any
---@private
highlights.get_property = function (property, groups, light, dark)
	---|fS

	local val;

	for _, item in ipairs(groups) do
		local hl = vim.api.nvim_get_hl(0, { name = item, link = false, create = false });

		if vim.fn.hlexists(item) == 1 and hl[property] then
			val = hl[property];
			break;
		end
	end

	local fallback = is_dark(light, dark);

	if property == "fg" or property == "bg" or property == "sp" then
		local converted, as_fallback = highlights.rgb(val or fallback);
		return as_fallback == false and converted or nil;
	else
		return val or fallback;
	end

	---|fE
end

------------------------------------------------------------------------------

--- Creates a palette(a collection of common highlight groups).
---@param n integer
---@param src string[]
---@param light any
---@param dark any
---@return table[]
highlights.create_pallete = function (n, src, light, dark)
	---|fS

	local bg = highlights.srgb_to_oklab(highlights.get_property(
		"bg",
		{ "Normal" },
		vim.g.patterns_light_bg or "#EFF1F5",
		vim.g.patterns_dark_bg or "#1E1E2E"
	));
	local fg = highlights.srgb_to_oklab(highlights.get_property(
		"fg",
		src,
		light or "#1E1E2E",
		dark or "#EFF1F5"
	));

	---@type number
	local alpha = vim.g.patterns_alpha or ( bg.L >= 0.5 and 0.15 or 0.25 );

	local _mix = highlights.mix(
		bg,
		fg,
		(1 - alpha),
		alpha
	) --[[ @as patterns.hl.Lab ]];

	local mix = highlights.oklab_to_srgb(_mix);
	local _fg = highlights.oklab_to_srgb(fg);

	local hover_fg = highlights.get_property(
		"fg",
		{ "Comment" },
		"#7c7f93",
		"#9399b2"
	);

	return {
		{
			group_name = string.format("PatternsPalette%d", n),
			value = {
				bg = highlights.rgb_to_hex(mix),
				fg = highlights.rgb_to_hex(_fg)
			}
		},
		{
			group_name = string.format("PatternsPalette%dFg", n),
			value = {
				fg = highlights.rgb_to_hex(_fg)
			}
		},
		{
			group_name = string.format("PatternsPalette%dBg", n),
			value = {
				bg = highlights.rgb_to_hex(mix),
				fg = highlights.rgb_to_hex(hover_fg),
			}
		},
	};

	---|fE
end

---@type table<string, patterns.hl>
highlights.groups = {
	---|fS

	["0"] = function ()
		return highlights.create_pallete(
			0,
			{ "Comment" },
			"#9CA0B0",
			"#6C7086"
		);
	end,
	["1"] = function ()
		return highlights.create_pallete(
			1,
			{ "@markup.heading.1.markdown", "@markup.heading", "markdownH1"  },
			"#D20F39",
			"#F38BA8"
		);
	end,
	["2"] = function ()
		return highlights.create_pallete(
			2,
			{ "@markup.heading.2.markdown", "@markup.heading", "markdownH2"  },
			"#FAB387",
			"#FE640B"
		);
	end,
	["3"] = function ()
		return highlights.create_pallete(
			3,
			{ "@markup.heading.3.markdown", "@markup.heading", "markdownH3"  },
			"#DF8E1D",
			"#F9E2AF"
		);
	end,
	["4"] = function ()
		return highlights.create_pallete(
			4,
			{ "@markup.heading.4.markdown", "@markup.heading", "markdownH4"  },
			"#40A02B",
			"#A6E3A1"
		);
	end,
	["5"] = function ()
		return highlights.create_pallete(
			5,
			{ "@markup.heading.5.markdown", "@markup.heading", "markdownH5"  },
			"#209FB5",
			"#74C7EC"
		);
	end,
	["6"] = function ()
		return highlights.create_pallete(
			6,
			{ "@markup.heading.6.markdown", "@markup.heading", "markdownH6"  },
			"#7287FD",
			"#B4BEFE"
		);
	end,
	["7"] = function ()
		return highlights.create_pallete(
			7,
			{ "@conditional", "@keyword.conditional", "Conditional" },
			"#8839EF",
			"#CBA6F7"
		);
	end,

	---|fE
};

---@param opt? table<string, patterns.hl>
highlights.setup = function (opt)
	if type(opt) == "table" then
		highlights.groups = vim.tbl_extend("force", highlights.groups, opt);
	end

	highlights.create(highlights.groups);
end

return highlights;
