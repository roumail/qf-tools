" qf-tools: toggle the quickfix window, copy between quickfix and location
" lists, and delete / restore entries from inside a list window.
if exists('g:loaded_qf_tools')
  finish
endif
let g:loaded_qf_tools = 1

command! QfToggle call qf_tools#toggle()
command! QuickFixToLocList call setloclist(0, getqflist())
command! LocListToQuickFix call setqflist(getloclist(0))

" <Plug> mappings; no keys are bound here (see README)
nnoremap <silent> <Plug>(qf-tools-toggle) <Cmd>call qf_tools#toggle()<CR>
" In a quickfix or location list window
nnoremap <silent> <Plug>(qf-tools-delete) <Cmd>call qf_tools#delete_item()<CR>
nnoremap <silent> <Plug>(qf-tools-undo) <Cmd>call qf_tools#undo()<CR>
