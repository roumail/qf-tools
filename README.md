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
| `dd` | quickfix / location list window | Remove the entry under the cursor. |
| `u` | quickfix / location list window | Put the last removed entry back. With nothing left to restore, go to the older list (`:colder` / `:lolder`). |

Removing entries edits the list in place, so it doesn't use up the 10-list
quickfix history.

## Install

```vim
Plug 'roumail/qf-tools'
```
