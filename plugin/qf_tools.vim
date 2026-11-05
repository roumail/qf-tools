" qf-tools: toggle the quickfix window, copy between quickfix and location
" lists, delete / restore entries from inside a list window, and save the
" quickfix list to load it back.
if exists('g:loaded_qf_tools')
  finish
endif
let g:loaded_qf_tools = 1

command! QfToggle call qf_tools#toggle()
command! QuickFixToLocList call setloclist(0, getqflist())
command! LocListToQuickFix call setqflist(getloclist(0))
" The quickfix list to a file and back: a path, or with vim-place a name kept
" per repository (<Tab> completes names)
command! -bang -nargs=1 -complete=customlist,qf_tools#save#complete QfSave
      \ call qf_tools#save#save(<bang>0, <q-args>)
command! -nargs=1 -complete=customlist,qf_tools#save#complete QfLoad
      \ call qf_tools#save#load(<q-args>)

" Toggle the quickfix window (as vim-unimpaired's yo* toggles options).
" dd / visual d / u in list windows: ftplugin/qf/qf_tools.vim
nnoremap <silent> yoq <Cmd>call qf_tools#toggle()<CR>
