# Tree-Sitter Powered Incremental Selection

Bring back `incremental_selection` of [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter/tree/master)

> [!NOTE]
> Neovim has builtin incremental selection since `v0.12`.
> Please check [:h treesitter-incremental-selection](https://neovim.io/doc/user/treesitter/#treesitter-incremental-selection)

## Installation

### vim.pack

```lua
vim.pack.add("https://github.com/d-itu/incsel.nvim", { load = false })
```

### lazy.nvim

This plugin can be lazily loaded.

```lua
{
    'd-itu/incsel.nvim',
    keys = {
        -- ...
    },
},
```

## Configuration

This plugin has no `setup`. It contains some functions which you can bind to your preferred keys.
Here is an example:

```lua
local incsel = require "incsel"
vim.keymap.set('n', '<CR>', function()
  if not incsel.init_selection() then
    vim.cmd "normal! \r\n"
  end
end, { desc = "Start selecting nodes with nvim-treesitter" })
vim.keymap.set('x', '<CR>', function()
  if not incsel.incremental() then
    vim.cmd "normal! \r\n"
  end
end, { desc = "Increment selection to named node" })
vim.keymap.set('x', '<BS>', function()
  if not incsel.decremental() then
    vim.cmd "normal \b"
  end
end, { desc = "Shrink selection to previous named node" })
```
