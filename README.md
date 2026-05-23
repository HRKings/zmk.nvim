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
        'x x',
        'x x',
        'x x',
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
                'x x x x x x x x x x x x',
                'x x x x x x x x x x x x',
                'x x x x x x x x x x x x',
                'x x x x x x x x x x x x',
                'x x x x x x x x x x x x',
                '_ _ _ _ _ x x _ _ _ _ _',
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
    layout = { 'x x' },
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
    layout = { 'x x' },
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
    "x x x _",
    "x _ ^xx"
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

The `layout` config describes your keyboard's physical layout.

A `layout` is a list of strings, where each string represents a single row. Rows must all be the same width, and you'll see they visually align to what your keymap looks like.

Valid keys are

- `x`: indicates presence of key
- ` `: space used to separate keys (must be used, and only use single spaces)
- `_`: indicates an empty space (e.g to split left and right, or adding padding)
- `x^x`: a key spanning multiple slots on the keyboard, the `^` indicates alignment. (NOTE vertically sized keys, like some thumb clusters, are not yet supported)
  - `^xx`: left align across two columns
  - `x^x`: center align
  - `xx^`: right align
  - `xx^xx`: center align but across three columns

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
