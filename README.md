# zmk.nvim

**zmk.nvim** is a 100% lua plugin for Neovim that formats [ZMK](https://zmk.dev/) keymaps, used in a large number of mechanical and hobbyist keyboards.

## Features

- automatically align your keymaps
- create a comment string of your keymap
- use inline JSON comments to make quick easy changes

Notes:

- any preprocessor macros must start with `_` if they are to be identified as the start of a key, e.g
  ```
  #define _AS(keycode) &as LS(keycode) keycode
  // ...etc
  default_layer {
      bindings = <
          &kp TAB _AS(Q) SOME_OTHER
      >;
  };
  ```

For a simple example of the following keymap

```
default_layer {
    bindings = <
        &kp A      &kp B,
            &kp C , &kp D,     // notice the white space
        &kp E ,  &kp HERE_BE_A_LONG_KEY // and how this doesn't line up at all
    >;
};
```

Setup your [layout](#Layout):

```lua
local zmk = require 'zmk'
zmk.setup {
    comment_preview = {
        keymap_overrides = {
            HERE_BE_A_LONG_KEY = 'Magic', -- replace any long key codes
        },
    },
    layout = { -- create a visual representation of your final layout
        '1 2',
        '3 4',
        '5 6',
    },
}
```

Save the file and it will automatically be nicely aligned, with a pretty comment string.

## Requirements

- Neovim >= 0.10
- Treesitter `devicetree` parser available (e.g through [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter#quickstart))
  - this can be used for `.keymap` files with `set ft=dts`

## Installation

- install with your favourite package manager
- call `setup` with your layout configuration

e.g:

```lua
{
    'codethread/zmk.nvim',
    config = function()
        ---@type zmk.UserConfig
        local conf = {
            layout = {
                '1  2  3  4  5  6  7  8  9  10 11 12',
                '13 14 15 16 17 18 19 20 21 22 23 24',
                '25 26 27 28 29 30 31 32 33 34 35 36',
                '37 38 39 40 41 42 43 44 45 46 47 48',
                '49 50 51 52 53 54 55 56 57 58 59 60',
                '_  _  _  _  _  61 62 _  _  _  _  _',
            }
        }
        require('zmk').setup(conf)
    end
}
```

## Configuration

zmk.nvim takes the following configuration (`---@type zmk.UserConfig`):

| setting                            | type                    | json | description                                                                                                                                                |
|------------------------------------|-------------------------|------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `layout`                           | `string[]` **required** | ✓    | the keyboard key layout, see [Layout](#Layout) for more details                                                                                            |
| `timeout`                          | `number`                |      | (default `5000`) duration of vim.notify timeout if using [nvim-notify](https://github.com/rcarriga/nvim-notify)                                            |
| `auto_format_pattern`              | `string`,`string[]`     |      | (default `{ '*.keymap' }`) the autocommand file pattern to use when applying [`ZMKFormat`](#Commands) on save                                              |
| `comment_preview`                  | `table`                 | ✓    | table of properties for rendering a pretty comment string of each keymap                                                                                   |
| `comment_preview.position`         | `top`,`bottom`,`none`   | ✓    | (default `top`) control the position of the preview, set to `none` to disable                                                                              |
| `comment_preview.keymap_overrides` | `table<string, string>` | ✓    | a dictionary of key codes to text replacements, any provided value will be merged with the existing dictionary, see [key_map.lua](./lua/zmk/config/key_map.lua) for details |
| `comment_preview.symbols`          | `table<string, string>` | ✓    | a dictionary of symbols used for the preview comment border chars see [default.lua](./lua/zmk/config/default.lua) for details                              |

### examples

<details>
  <summary>Disabling most features</summary>

```lua
{
    layout = { '1 2' },
    auto_format_pattern = nil,
    comment_preview = {
        position = 'none'
    }
}
```

</details>

<details>
  <summary>Overriding a long key code</summary>

```lua
{
    layout = { '1 2' },
    comment_preview = {
        position = 'top',
        keymap_overrides = {
            -- key codes are matched literally against the entire key in your layout
            -- longer key codes are checked first, and these will replace the value displayed in the preview
            --
            -- lua magic patterns used to need escaping with `%` but not anymore
            -- old escaped patterns should still work though
            -- watch out for emojis as they are double width
            ['&mt LCMD GRAVE'] = 'CYCLE WIN',
        },
    },
}
```

</details>

<details>
  <summary>Using inline JSON</summary>

A comment block can be added at the bottom of your config file. Inline configs will be reparsed on every call to ZMK functions, and then merged with your main config.

**It must**

- be a block comment to avoid extra comment symbols
- be surrounded with `zmk:json:start` and end with `zmk:json:end`
- see [config](#Configuration) for supported fields

e.g.:

```
/*
zmk:json:start
{
  "layout": [
    "1 2 3 _",
    "4 _ 5 5"
  ],
  "comment_preview": {
    "keymap_overrides": {
      "BAR": "BUTTER",
      "FOO": "😎"
    }
  }
}
zmk:json:end
*/
```

</details>

<details>
  <summary>Tree-sitter syntax highlighting for inline JSON</summary>

`zmk.nvim` includes a [`Tree-sitter` language injection query](https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html?highlight=injection#language-injection) that enables syntax highlighting for the inline JSON.
If you have `Tree-sitter` enabled and `zmk.nvim` is loaded **before** `nvim-treesitter` (e.g. by setting `zmk.nvim` as a dependency for `nvim-treesitter`) it will be enabled automatically.
Alternatively, you can copy the `queries/devicetree/injections.scm` to your nvim config.

</details>

## Layout

The `layout` describes your keyboard's physical layout using **position indices** —
each token is the 1-based index of a binding from your keymap's `bindings = <...>`
list. Order in the layout does not need to match order in the bindings, so disjoint
islands (encoder clusters, arrow clusters, thumb keys with offsets) work naturally.

Layout = list of strings, one string per row. All rows must have the same number
of tokens (use `_` to pad).

Tokens:

- `1`, `2`, `42`, ... : a positive integer = position N from the bindings array
- `_` : an empty cell (gap). Used for offsets and to separate islands so each
  island renders with its own border.
- Repeating the same index in consecutive cells on one row marks a horizontal
  span: `5 5 5` = key 5 occupies 3 cells. Vertical spans (same index across rows)
  are not supported.

Rules:

- Every binding index from 1 to N (where N = number of bindings) must appear
  exactly once (or as one contiguous span run).
- Multiple spaces between tokens are allowed and ignored — handy for aligning
  multi-digit indices visually.

### Islands example

A keyboard with main left half (6 cols × 2 rows), middle cluster (3 cols × 2 rows
where row 1 has just a centered key) and main right half (5 cols × 2 rows):

```lua
layout = {
  '1  2  3  4  5  6  _  _  7  _  _  8  9  10 11 12',
  '13 14 15 16 17 18 _  19 20 21 _  22 23 24 25 26',
}
```

The middle cluster (indices 7, 19, 20, 21) is surrounded by `_` gaps so it gets
its own preview border, independent column widths and is not visually attached to
the left or right halves.

## Usage

### Commands

- `ZMKFormat`: format the current buffer

### lua

- `:lua require('zmk').setup( <config> )`: setup zmk using your [config](#Configuration) (must be called before format, can be called repeatedly)
- `:lua require('zmk').format( <buf id ?> )`: format a given buffer, or the current if <buf id> is not provided

### Autocommands

- A `BufWritePre` autocmd will format buffers on save matching `config.auto_format_pattern` (defaults to `*.keymap`, set to `nil` to disable)

## Debugging

Getting your layout right may be an iterative process, so I recommend the following:

- open a scratch buffer next to your `.keymap` file
- get the buffer id of your keymap file with `:lua print(vim.api.nvim_get_current_buf())`
- in your scratch buffer, call `zmk.setup { .. your config }` and `zmk.format(<buf id>)`
- from within your scratch buffer evaluate with `luafile %`

### Errors

I have tried to create useful errors when something is wrong with the config, layout or your current keymap, but please raise an issue if something isn't clear (or you get a `ZMK: E00`, as that's definitely on me).
