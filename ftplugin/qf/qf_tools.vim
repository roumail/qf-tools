" In quickfix and location list windows: dd removes the entry under the
" cursor (3dd three of them), d in visual mode those selected; u puts back
" what the last of them removed
nnoremap <buffer> <silent> dd <Cmd>call qf_tools#delete(line('.'), line('.') + v:count1 - 1)<CR>
xnoremap <buffer> <silent> d :<C-u>call qf_tools#delete(line("'<"), line("'>"))<CR>
nnoremap <buffer> <silent> u <Cmd>call qf_tools#undo()<CR>
