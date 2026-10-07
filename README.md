# qf-tools

Small helpers for the quickfix and location lists.

| Command | What it does |
| --- | --- |
| `:QfToggle` | Open the quickfix window, or close it if one is open. |
| `:QuickFixToLocList` | Copy the quickfix list into the current window's location list. |
| `:LocListToQuickFix` | Copy the location list into the quickfix list. |

| `<Plug>` mapping | What it does |
| --- | --- |
| `<Plug>(qf-tools-toggle)` | `:QfToggle` |
| `<Plug>(qf-tools-delete)` | In a quickfix / location list window: remove the entry under the cursor. |
| `<Plug>(qf-tools-undo)` | Put the last removed entry back. With nothing left to restore, go to the older list (`:colder` / `:lolder`). |

Removing entries edits the list in place, so it doesn't use up the 10-list
quickfix history.

No keys are bound. For example, in `~/.vim/after/ftplugin/qf.vim`:

```vim
nmap <buffer> dd <Plug>(qf-tools-delete)
nmap <buffer> u <Plug>(qf-tools-undo)
```

and in your vimrc:

```vim
nmap yoq <Plug>(qf-tools-toggle)
```

## Install

```vim
Plug 'roumail/qf-tools'
```
