# mc.nvim

## What Is MC?
MC stands for Multiple Cursors. 
MC is a plugin that adds a bunch of virtual cursors into `Neovim`, writing in `Lua`

## Getting Started

This section should guide you to run MC on your `Neovim`.

### Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'YacineDo/mc.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('YacineDo/mc.nvim')
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'YacineDo/mc.nvim'
```

### Basic usage:

- select words with <kbd>Ctrl-N</kbd> (like `Ctrl-d` in Sublime Text/VS Code)
- create cursors vertically with <kbd>Ctrl-Down</kbd>/<kbd>Ctrl-Up</kbd>
- select one character at a time with <kbd>Shift-Arrows</kbd>
- press <kbd>n</kbd>/<kbd>N</kbd> to get next/previous occurrence
- press <kbd>[</kbd>/<kbd>]</kbd> to select next/previous cursor
- press <kbd>q</kbd> to skip current and get next occurrence
- press <kbd>Q</kbd> to remove current cursor/selection
- start insert mode with <kbd>i</kbd>,<kbd>a</kbd>,<kbd>I</kbd>,<kbd>A</kbd>
