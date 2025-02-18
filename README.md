# 🧩 patterns.nvim

<div align="center">
    <img alt="Neovim" src="https://img.shields.io/badge/Neovim-000?style=for-the-badge&logo=neovim&logoColor=A6E3A1&color=1E1E2E">
    <img alt="Repo size" src="https://img.shields.io/github/languages/code-size/OXY2DEV/patterns.nvim?style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0NDggNTEyIj48IS0tIUZvbnQgQXdlc29tZSBGcmVlIDYuNy4yIGJ5IEBmb250YXdlc29tZSAtIGh0dHBzOi8vZm9udGF3ZXNvbWUuY29tIExpY2Vuc2UgLSBodHRwczovL2ZvbnRhd2Vzb21lLmNvbS9saWNlbnNlL2ZyZWUgQ29weXJpZ2h0IDIwMjUgRm9udGljb25zLCBJbmMuLS0%2BPHBhdGggc3Ryb2tlPSIjQ0JBNkY3IiBmaWxsPSIjQ0JBNkY3IiBkPSJNOTYgMEM0MyAwIDAgNDMgMCA5NkwwIDQxNmMwIDUzIDQzIDk2IDk2IDk2bDI4OCAwIDMyIDBjMTcuNyAwIDMyLTE0LjMgMzItMzJzLTE0LjMtMzItMzItMzJsMC02NGMxNy43IDAgMzItMTQuMyAzMi0zMmwwLTMyMGMwLTE3LjctMTQuMy0zMi0zMi0zMkwzODQgMCA5NiAwem0wIDM4NGwyNTYgMCAwIDY0TDk2IDQ0OGMtMTcuNyAwLTMyLTE0LjMtMzItMzJzMTQuMy0zMiAzMi0zMnptMzItMjQwYzAtOC44IDcuMi0xNiAxNi0xNmwxOTIgMGM4LjggMCAxNiA3LjIgMTYgMTZzLTcuMiAxNi0xNiAxNmwtMTkyIDBjLTguOCAwLTE2LTcuMi0xNi0xNnptMTYgNDhsMTkyIDBjOC44IDAgMTYgNy4yIDE2IDE2cy03LjIgMTYtMTYgMTZsLTE5MiAwYy04LjggMC0xNi03LjItMTYtMTZzNy4yLTE2IDE2LTE2eiIvPjwvc3ZnPg%3D%3D&logoColor=CBA6F7&labelColor=1e1e2e&color=B4BEFE">
    <img alt="GitHub Release" src="https://img.shields.io/github/v/release/OXY2DEV/patterns.nvim?include_prereleases&sort=semver&display_name=release&style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MTIgNTEyIj48IS0tIUZvbnQgQXdlc29tZSBGcmVlIDYuNy4yIGJ5IEBmb250YXdlc29tZSAtIGh0dHBzOi8vZm9udGF3ZXNvbWUuY29tIExpY2Vuc2UgLSBodHRwczovL2ZvbnRhd2Vzb21lLmNvbS9saWNlbnNlL2ZyZWUgQ29weXJpZ2h0IDIwMjUgRm9udGljb25zLCBJbmMuLS0%2BPHBhdGggZmlsbD0iI0Y1RTBEQyIgc3Ryb2tlPSIjRjVFMERDIiBkPSJNMzQ1IDM5LjFMNDcyLjggMTY4LjRjNTIuNCA1MyA1Mi40IDEzOC4yIDAgMTkxLjJMMzYwLjggNDcyLjljLTkuMyA5LjQtMjQuNSA5LjUtMzMuOSAuMnMtOS41LTI0LjUtLjItMzMuOUw0MzguNiAzMjUuOWMzMy45LTM0LjMgMzMuOS04OS40IDAtMTIzLjdMMzEwLjkgNzIuOWMtOS4zLTkuNC05LjItMjQuNiAuMi0zMy45czI0LjYtOS4yIDMzLjkgLjJ6TTAgMjI5LjVMMCA4MEMwIDUzLjUgMjEuNSAzMiA0OCAzMmwxNDkuNSAwYzE3IDAgMzMuMyA2LjcgNDUuMyAxOC43bDE2OCAxNjhjMjUgMjUgMjUgNjUuNSAwIDkwLjVMMjc3LjMgNDQyLjdjLTI1IDI1LTY1LjUgMjUtOTAuNSAwbC0xNjgtMTY4QzYuNyAyNjIuNyAwIDI0Ni41IDAgMjI5LjV6TTE0NCAxNDRhMzIgMzIgMCAxIDAgLTY0IDAgMzIgMzIgMCAxIDAgNjQgMHoiLz48L3N2Zz4%3D&labelColor=1E1E2E&color=45475A">
</div>

A simple & bare-bones pattern explainer & editor for Neovim.

## 📖 Table of contents

- [✨ Features](#-features)
- [📚 Requirements](#-requirements)
- [📐 Installation](#-installation)
- [🧭 Configuration](#-configuration)
- [💡 Commands](#-commands)
- [🎹 keymaps](#-keymaps)

## ✨ Features

- Tree-sitter based pattern explainer.
- LSP-like hover window for strings.
- A real-time pattern editor & matcher.
- Support for multiple pattern languages,

    + `regex`
    + `lua_patterns`(requires custom parser)

- Highly configurable! Almost everything can be configured(without needing to leave your editor).

## 📚 Requirements

- Tree-sitter parser.

    + `regex`(install through `nvim-treesitter` via `:TSInstall regex`)
    + `lua_patterns`(optional, See [parser installation](#-parser-installation)).

- A tree-sitter supported colorscheme(optional).
- A nerd font.

## 📐 Installation

### 🧩 Vim-plug

Add this to your plugin list.

```vim
Plug "OXY2DEV/patterns.nvim"
```

### 💤 lazy.nvim

>[!NOTE]
> Lazy loading is NOT needed for this plugin!

For `plugins.lua` users,

```lua
{
    "OXY2DEV/patterns.nvim",
},
```

For `plugins/patterns.lua`,

```lua
return {
    "OXY2DEV/patterns.nvim",
};
```

## 🦠 mini.deps

```lua
local MiniDeps = require("mini.deps");

MiniDeps.add({
    source = "OXY2DEV/patterns.nvim"
});
```

### 🌒 Rocks.nvim

>[!WARNING]
> `luarocks package` may sometimes be a bit behind `main`.

```vim
:Rocks install patterns.nvim
```

### 📥 GitHub release

Tagged releases can be found in the [release page](https://github.com/OXY2DEV/patterns.nvim/releases).

>[!NOTE]
> `Github releases` may sometimes be slightly behind `main`.

## 🧭 Configuration

See the default configuration [here](hello).

<details>
    <summary>Show type definitions</summary>

```lua
--- Configuration for `patterns.nvim`.
---@class patterns.config
---
---@field keymaps? patterns.keymaps
---@field windows patterns.windows
---@field lua_patterns patterns.lua_patterns
---@field regex patterns.regex

---@class patterns.keymaps
---
---@field hover table<string, patterns.keymap_opts>
---@field explain_input table<string, patterns.keymap_opts>
---@field explain_preview table<string, patterns.keymap_opts>


--- Action names for the explainer.
---@alias explain_actions
---| "toggle" Toggle focus of window.
---| "mode_change" Switches between the explainer & the matcher.
---
--- Changes pattern language backwards.
---| "lang_prev"
---| "lang_next" Changes pattern language forwards.
---
--- Closes explainer.
---| "close"
---| "apply" Applies changes.


--- Action names for the hover.
---@alias hover_actions
---| "close" Closes hover window.
---| "edit" Edit pattern.

---@class patterns.keymap_opts
---
---@field desc? string
---@field callback explain_actions | hover_actions | function


--- Window configurations for various
--- windows.
---@class patterns.windows
---
---@field hover? table | fun(q1: "left" | "right" | "center", q2: "top" | "bottom" | "center"): table
---
---@field input? table | fun(): table
---@field preview? table | fun(): table


--- Options for Lua patterns.
--- Option name matches the tree-sitter node name.
---@class patterns.lua_patterns
---
---@field indent_size integer Indentation size.
---@field indent_marker string Marker used for indentation.
---@field indent_hl? string Highlight group for the indentation markers.
---
---@field pattern pattern_item.opts
---
---@field anchor_start pattern_item.opts
---@field anchor_end pattern_item.opts
---
---@field quantifier_optional pattern_item.opts
---@field quantifier_minus pattern_item.opts
---@field quantifier_plus pattern_item.opts
---@field quantifier_star pattern_item.opts
---
---@field literal_character pattern_item.opts
---@field any_character pattern_item.opts
---@field escape_sequence pattern_item.opts
---@field escaped_character pattern_item.opts
---
---@field capture_group pattern_item.opts
---@field character_set pattern_item.opts
---@field character_set_content pattern_item.opts
---@field character_range pattern_item.opts
---@field character_class pattern_item.opts


--- Options for Regex.
--- Option name matches the tree-sitter node name.
---@class patterns.regex
---
---@field indent_size integer Indentation size.
---@field indent_marker string Marker used for indentation.
---@field indent_hl? string Highlight group for the indentation markers.
---
---@field pattern pattern_item.opts
---@field alternation pattern_item.opts
---@field term pattern_item.opts
---
---@field start_assertion pattern_item.opts
---@field end_assertion pattern_item.opts
---@field boundary_assertion pattern_item.opts
---@field non_boundary_assertion pattern_item.opts
---@field lookaround_assertion pattern_item.opts
---
---@field quantifier_count pattern_item.opts
---@field quantifier_optional pattern_item.opts
---@field quantifier_plus pattern_item.opts
---@field quantifier_star pattern_item.opts
---
---@field pattern_character pattern_item.opts
---@field class_character pattern_item.opts
---@field any_character pattern_item.opts
---@field decimal_escape pattern_item.opts
---@field character_class_escape pattern_item.opts
---@field unicode_character_escape pattern_item.opts
---@field unicode_property_value pattern_item.opts
---@field control_escape pattern_item.opts
---@field control_letter_escape pattern_item.opts
---@field identity_escape pattern_item.opts
---@field backreference_escape pattern_item.opts
---@field unicode_property_value_expression pattern_item.opts
---
---@field character_class pattern_item.opts
---@field posix_character_class pattern_item.opts
---@field named_group_backreference pattern_item.opts
---@field capturing_group pattern_item.opts
---@field non_capturing_group pattern_item.opts
---
---@field flags_group pattern_item.opts
---@field flags pattern_item.opts


--- Options for each node type.
---@class pattern_item.opts
---
--- Can be set to `false` to disable rendering of 
--- a specific node type.
---@field enable? boolean | fun(buffer: integer, item: __patterns.item): boolean
---
--- Can be set to `true` to show the range of a
--- node.
---@field show_range? boolean | fun(buffer: integer, item: __patterns.item): boolean
---
--- Highlight group for the text.
---@field text_hl? string | fun(buffer: integer, item: __patterns.item): string?
---
--- Text to show for a node.
---@field text? string | fun(buffer: integer, item: __patterns.item): string
---
--- When set to `true`, shows tooltip for nodes.
--- By default this only shows tips for the current
--- node.
---@field show_tip? boolean | fun(buffer: integer, item: __patterns.item): boolean
---
--- Highlight group for the tooltip text.
---@field tip_hl? string | fun(buffer: integer, item: __patterns.item): string
---
--- Number of spaces to add before tooltip text.
--- This is added AFTER the indentation.
---@field tip_offset? integer | fun(buffer: integer, item: __patterns.item): integer
---
--- Highlight group for the node range.
---@field range_hl? string | fun(buffer: integer, item: __patterns.item): string?
---
--- Bade highlight group. Used by other *_hl
--- options when they don't have a value.
---@field hl? string | fun(buffer: integer, item: __patterns.item): string?
```

</details>

<details>
    <summary>Show default configuration</summary>

```lua
spec.default = {
	keymaps = {
		explain_input = {
			["<CR>"] = {
				callback = "apply"
			},
			["q"] = {
				callback = "close"
			},

			["<tab>"] = {
				callback = "toggle"
			},

			["H"] = {
				callback = "lang_prev"
			},
			["L"] = {
				callback = "lang_next"
			},
		},
		explain_preview = {
			["q"] = {
				callback = "close"
			},

			["<tab>"] = {
				callback = "toggle"
			},

			["T"] = {
				callback = "mode_change"
			}
		},

		hover = {
			["q"] = {
				callback = "close"
			},
			["i"] = {
				callback = "edit"
			}
		}
	},
	windows = {
		hover = function (q1, q2)
			local border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" };

			if q2 == "top" then
				if q1 == "left" then
					border[5] = "┤";
				elseif q1 == "right" then
					border[7] = "├";
				end
			elseif q2 == "bottom" then
				if q1 == "left" then
					border[3] = "┤";
				elseif q1 == "right" then
					border[1] = "├";
				end
			end

			local ft;

			if package.loaded["patterns.hover"] and package.loaded["patterns.hover"].buf then
				ft = vim.bo[package.loaded["patterns.hover"].buf].ft;
			end

			return {
				width = math.floor(vim.o.columns * 0.6),
				height = math.floor(vim.o.lines * 0.5),

				border = border,

				footer_pos = "right",
				footer = {
					{ "╸", "FloatBorder" },
					{ " 󰛪 " .. (ft or "Patterns") .. " ", "FloatBorder" },
					{ "╺", "FloatBorder" },
				}
			}
		end
	},

	lua_patterns = {
		indent_size = 2,
		indent_marker = "│",
		indent_hl = "PatternsPalette0Fg",

		pattern = {
			text = "󰐱 Pattern",
			show_tip = on_current,

			tip_hl = "PatternsPalette0Bg",
			hl = "PatternsPalette0";
		},

		----------------------------------------

		anchor_start = {
			text = "󰾺 From start",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		anchor_end = {
			text = "󰾸 To end",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		----------------------------------------

		quantifier_minus = {
			text = "󰑖 Zero or more times(non-greedily)",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_optional = {
			text = "󰑘 Zero or one time",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_plus = {
			text = "󰑘 One or more times",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_star = {
			text = "󰑖 Zero or more times(greedily)",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		----------------------------------------

		literal_character = {
			text = function (_, item)
				if item.text == "\\" then
					return '󱄽 Character: "\\"';
				else
					return string.format("󱄽 Character: %s", vim.inspect(item.text));
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette4Bg",
			hl = "PatternsPalette4"
		},

		any_character = {
			text = " Any character",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		escape_sequence = {
			text = function (_, item)
				return string.format('󰩈 Escape sequence: "%s"', item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		escaped_character = {
			text = function (_, item)
				return string.format('󰩈 Escaped character: "%s"', item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		----------------------------------------

		capture_group = {
			text = function (_, item)
				return string.format(" Capture group, 󱤬 %d", item.id or -1);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		character_set = {
			text = "󱉓 Character set",
			show_tip = on_current,

			tip_hl = "PatternsPalette3Bg",
			hl = "PatternsPalette3"
		},

		character_set_content = {
			text = "󰆦 Character set content,",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		character_range = {
			text = function (_, item)
				return string.format("󰊱 Character range: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		character_class = {
			text = function (_, item)
				return "󰏗 Character class: " .. vim.inspect(item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette4Bg",
			hl = "PatternsPalette4"
		},
	},

	regex = {
		indent_size = 2,
		indent_marker = "│",
		indent_hl = "PatternsPalette0Fg",

		pattern = {
			text = "󰛪 Pattern",
			show_tip = on_current,

			tip_hl = "PatternsPalette0Bg",
			hl = "PatternsPalette0"
		},

		alternation = {
			text = "󰋰 Alternative pattern(s)",
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		term = {
			text = function (_, item)
				return string.format("󰊲 Regex term(#%d)", item.id or -1);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		----------------------------------------

		start_assertion = {
			text = "󰾺 From start",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		end_assertion = {
			text = "󰾸 To end",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		boundary_assertion = {
			text = "󰕤 Match as a word",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		non_boundary_assertion = {
			text = "󰕛 Match as part of a word",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		lookaround_assertion = {
			text = function (_, item)
				if string.match(item.text, "^%(%?%<") then
					return "󰡭 Look behind";
				else
					return "󰡮 Look ahead";
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette3Bg",
			hl = "PatternsPalette3"
		},

		----------------------------------------

		quantifier_count = {
			text = function (_, item)
				if string.match(item.text, "^%d+$") then
					return string.format(" Repeats exactly %s times", item.text);
				elseif string.match(item.text, "^%d+,$") then
					return string.format(
						" Repeats at least %s times",
						string.match(item.text, "^(%d+)")
					);
				elseif string.match(item.text, "^,%d+$") then
					return string.format(
						" Repeats at most %s times",
						string.match(item.text, "^,(%d+)$")
					);
				else
					return string.format(
						" Repeats between %s & %s times",
						string.match(item.text, "^(%d+),"),
						string.match(item.text, "^%d+,(%d+)$")
					);
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_optional = {
			text = " Repeats zero or one time",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_plus = {
			text = " Repeats one or more times",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		quantifier_star = {
			text = " Repeats zero or more times",
			show_tip = on_current,

			tip_hl = "PatternsPalette7Bg",
			hl = "PatternsPalette7"
		},

		----------------------------------------

		pattern_character = {
			text = function (_, item)
				return string.format("󱄽 Character: %s", vim.inspect(item.text));
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},

		class_character = {
			text = function (_, item)
				return string.format("󱄽 Character: %s", vim.inspect(item.text));
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},

		any_character = {
			text = " Any character",
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		decimal_escape = {
			text = function (_, item)
				return string.format("󰩈 Decimal escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		character_class_escape = {
			text = function (_, item)
				return string.format("󰩈 Character class escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		unicode_character_escape = {
			text = function (_, item)
				return string.format("󰩈 Unicode character escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		unicode_property_value = {
			text = function (_, item)
				return string.format("󰗊 Unicode property value: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette6Bg",
			hl = "PatternsPalette6"
		},

		control_escape = {
			text = function (_, item)
				return string.format("󰁨 Control character escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		control_letter_escape = {
			text = function (_, item)
				return string.format("󰁨 Control letter escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		identity_escape = {
			text = function (_, item)
				return string.format("󰩈 Identity escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		backreference_escape = {
			text = function (_, item)
				return string.format("󰒻 Backreference escape: %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette1Bg",
			hl = "PatternsPalette1"
		},

		----------------------------------------

		unicode_property_value_expression = {
			text = "󰁀 Unicode property value expression",
			show_tip = on_current,

			-- show_content = true,
			tip_hl = "PatternsPalette0Bg",
			hl = "PatternsPalette0"
		},

		----------------------------------------

		character_class = {
			text = "󰏗 Character class",
			show_tip = on_current,

			tip_hl = "PatternsPalette4Bg",
			hl = "PatternsPalette4"
		},

		posix_character_class = {
			text = function (_, item)
				return string.format("󰏗 POSIX Character class: ", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		named_group_backreference = {
			text = function (_, item)
				return string.format("󰒻 Named backreference: ", string.match(item.text, "^%(%?P%=(.-)%)$"));
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		capturing_group = {
			text = function (_, item)
				if type(item.id) == "string" then
					return string.format("󱉶 Capture group(#%s)", item.id or "???");
				else
					return string.format("󱉶 Capture group(#%d)", item.id or -1);
				end
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		non_capturing_group = {
			text = function (_, item)
				return string.format("󰒉 Non-capture group(#%d)", item.id or -1);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette5Bg",
			hl = "PatternsPalette5"
		},

		flags_group = {
			text = "󰂖 Flags group",
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},

		flags = {
			text = function (_, item)
				return string.format("󰈻 Flag(s): %s", item.text);
			end,
			show_tip = on_current,

			tip_hl = "PatternsPalette2Bg",
			hl = "PatternsPalette2"
		},
	}
};
```

</details>


## 💡 Commands

This plugin creates the `:Patterns` command. It has 2 sub-commands,

- `explain`
  Explains the pattern under the cursor.

- `hover`
  LSP-like hover for the pattern under cursor.
  It's behavior is similar to `K`(or `vim.lsp.buf.hover()`).

When `:Patterns` is run without any arguments, it opens the explain window.

## 🎹 keymaps

The `hover` & `explain` buffers have some pre-defined keymaps.

>[!TIP]
> You can disable these keymaps individually via the config.
>
> ```lua
> {
>   keymaps = {
>     hover = {
>       ["i"] = { enable = false }
>     }
>   }
> }
> ```

### ⭐ hover

The hover buffer has the following keymaps,

+ `q`
  Closes hover window.

+ `i`
  Opens the pattern inside the explainer.


### ⭐ explain

#### ⭐ explain_input

The text input buffer has the following keymaps,

+ `<CR>`
  Replaces the pattern under cursor with the text in the input buffer.

+ `q`
  Quits the explainer.

+ `<tab>`
  Switches to the explanation/preview buffer.

+ `H`
  Cycles backward through the list of supported languages(lua_patterns, regex).

+ `L`
  Cycles forward through the list of supported languages(lua_patterns, regex).

#### ⭐ explain_preview

The pattern preview/explanation buffer has the following keymaps,

+ `q`
  Quits the explainer.

+ `<tab>`
  Switches to the input buffer.

+ `T`
  Toggles between the explanation and the matcher.

