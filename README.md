# qf-tools

Small helpers for the quickfix and location lists.

| Command | What it does |
| --- | --- |
| `:QfToggle` | Open the quickfix window, or close it if one is open. |
| `:QuickFixToLocList` | Copy the quickfix list into the current window's location list. |
| `:LocListToQuickFix` | Copy the location list into the quickfix list. |

| Key | Where | What it does |
| --- | --- | --- |
| `yoq` | anywhere | `:QfToggle` |
| `dd` | quickfix / location list window | Remove the entry under the cursor; `3dd` three of them. |
| `d` (visual) | quickfix / location list window | Remove the selected entries. |
| `u` | quickfix / location list window | Put back what the last `dd` or `d` removed. With nothing left to restore, go to the older list (`:colder` / `:lolder`). |

Removing entries edits the list in place, so it doesn't use up the 10-list
quickfix history.

## For other plugins

After `dd`, `d` or `u` changes a list, `User QfToolsChanged` fires, with
the list window current, so a plugin can keep track of what was removed
from a list of its own:

```vim
autocmd User QfToolsChanged call MyPluginSync()
```

## Install

```vim
Plug 'roumail/qf-tools'
```
