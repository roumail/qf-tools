" In quickfix and location list windows: dd removes the entry under the
" cursor, u puts it back
nnoremap <buffer> <silent> dd <Cmd>call qf_tools#delete_item()<CR>
nnoremap <buffer> <silent> u <Cmd>call qf_tools#undo()<CR>
