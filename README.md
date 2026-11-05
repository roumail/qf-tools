# qf-tools

Small helpers for the quickfix and location lists.

| Command | What it does |
| --- | --- |
| `:QfToggle` | Open the quickfix window, or close it if one is open. |
| `:QuickFixToLocList` | Copy the quickfix list into the current window's location list. |
| `:LocListToQuickFix` | Copy the location list into the quickfix list. |
| `:QfSave[!] {name\|path}` | Write the quickfix list to a file: its title, its entries and what a plugin keeps on them, so a list such as pytest.vim's `:PytestTests` works as before once loaded. A path (with a `/`, or starting with `~` or `.`) needs `!` to overwrite a file; a name is saved again. |
| `:QfLoad {name\|path}` | Load a saved list as a new quickfix list, so `:colder` goes back to the one before it. `<Tab>` completes names. |

| Key | Where | What it does |
| --- | --- | --- |
| `yoq` | anywhere | `:QfToggle` |
| `dd` | quickfix / location list window | Remove the entry under the cursor; `3dd` three of them. |
| `d` (visual) | quickfix / location list window | Remove the selected entries. |
| `u` | quickfix / location list window | Put back what the last `dd` or `d` removed. With nothing left to restore, go to the older list (`:colder` / `:lolder`). |

Removing entries edits the list in place, so it doesn't use up the 10-list
quickfix history.

To keep a list you pruned with `dd` before a plugin rebuilds it,
`:QfSave` it, and `:QfLoad` it later. What a plugin keeps on a list that
can't be written as JSON (a function) is left out, and `:QfSave` says so.
The location list is saved by copying it first: `:LocListToQuickFix`.

## For other plugins

After `dd`, `d` or `u` changes a list, `User QfToolsChanged` fires, with
the list window current, so a plugin can keep track of what was removed
from a list of its own:

```vim
autocmd User QfToolsChanged call MyPluginSync()
```

## Install

The core is qf-tools on its own:

```vim
Plug 'roumail/qf-tools'
```

That gives you every command and key, with `:QfSave` and `:QfLoad` to a
path you give.

Each row below adds a module on top of the core, and **Needs** is the whole
set of plugins it takes besides the core:

| Needs | Module | Adds |
| --- | --- | --- |
| [vim-place](https://github.com/roumail/vim-place) + [vim-fugitive](https://github.com/tpope/vim-fugitive) | Named lists | `:QfSave {name}` and `:QfLoad {name}`, kept in `qf-tools/` where vim-place keeps plugins' files (the git dir, shared by work trees), with paths relative to the work tree |

All of it:

```vim
Plug 'tpope/vim-fugitive'
Plug 'roumail/vim-place'
Plug 'roumail/qf-tools'
```

## Tests

```sh
vim -Nu NONE -i NONE -Es -S test/run.vim
```

vim-place and vim-fugitive come from `$VIM_PLACE` and `$FUGITIVE`, else
vim-plug's copies.
