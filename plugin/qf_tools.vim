" qf-tools: toggle the quickfix window, copy between quickfix and location
" lists, and delete / restore entries from inside a list window.
if exists('g:loaded_qf_tools')
  finish
endif
let g:loaded_qf_tools = 1

command! QfToggle call qf_tools#toggle()
command! QuickFixToLocList call setloclist(0, getqflist())
command! LocListToQuickFix call setqflist(getloclist(0))

" Toggle the quickfix window (as vim-unimpaired's yo* toggles options).
" dd / u in list windows: ftplugin/qf/qf_tools.vim
nnoremap <silent> yoq <Cmd>call qf_tools#toggle()<CR>
