" Headless tests, from the repository's root:
"   vim -Nu NONE -i NONE -Es -S test/run.vim
" Prints one line per test and exits non-zero when one fails; TEST=<pattern>
" in the environment runs the tests whose names match. vim-place and
" vim-fugitive, for names, come from $VIM_PLACE and $FUGITIVE, else
" vim-plug's copies.
set nocompatible hidden
execute 'set runtimepath^=' . fnameescape(expand('<sfile>:p:h:h'))
let s:fugitive = empty($FUGITIVE) ? expand('~/.vim/plugged/vim-fugitive') : $FUGITIVE
let s:place = empty($VIM_PLACE) ? expand('~/.vim/plugged/vim-place') : $VIM_PLACE
execute 'set runtimepath^=' . fnameescape(s:fugitive)
execute 'set runtimepath^=' . fnameescape(s:place)
execute 'source' fnameescape(s:fugitive . '/plugin/fugitive.vim')
execute 'source' fnameescape(expand('<sfile>:p:h:h') . '/plugin/qf_tools.vim')

let s:tmp = resolve(tempname())
let s:repo = s:tmp . '/repo'
let s:out = []

function! s:reset() abort
  silent! only!
  silent! %bwipeout!
  call setqflist([], 'f')
  call delete(s:tmp, 'rf')
  call mkdir(s:repo . '/tests', 'p')
  call system('git -C ' . shellescape(s:repo) . ' init -q')
  call writefile(['one', 'two', 'three'], s:repo . '/tests/a.py')
  call writefile(['x'], s:repo . '/b.py')
  execute 'cd' fnameescape(s:repo)
endfunction

" A list as a plugin makes one: its title, a context of its own, and data
" on each entry
function! s:list() abort
  call setqflist([], ' ', {'title': 'Tests', 'context': {'pytest': 'tests'}, 'items': [
        \ {'filename': s:repo . '/tests/a.py', 'lnum': 2, 'text': 'test_two',
        \  'user_data': {'nodeid': 'tests/a.py::test_two'}},
        \ {'filename': s:repo . '/b.py', 'lnum': 1, 'text': 'b'},
        \ {'text': 'a line of output, no file'}]})
endfunction

" assert_fails() makes vim -Es exit non-zero even when it passes
function! s:message(cmd) abort
  return execute(a:cmd)
endfunction

function! s:test_save_and_load_a_name() abort
  call s:list()
  silent QfSave wip
  call assert_true(filereadable(s:repo . '/.git/qf-tools/wip.json'))
  " Paths in a named save are the work tree's
  call assert_match('"filename":"tests/a.py"', readfile(s:repo . '/.git/qf-tools/wip.json')[0])
  call setqflist([], ' ', {'title': 'other', 'items': []})
  silent QfLoad wip
  let l:list = getqflist({'title': 1, 'context': 0, 'items': 1})
  call assert_equal('Tests', l:list.title)
  call assert_equal({'pytest': 'tests'}, l:list.context)
  call assert_equal(3, len(l:list.items))
  call assert_equal(s:repo . '/tests/a.py', fnamemodify(bufname(l:list.items[0].bufnr), ':p'))
  call assert_equal(2, l:list.items[0].lnum)
  call assert_equal({'nodeid': 'tests/a.py::test_two'}, l:list.items[0].user_data)
  call assert_equal(0, l:list.items[2].bufnr)
  call assert_equal('a line of output, no file', l:list.items[2].text)
  " A new list: the one before it is still there
  call assert_equal(3, getqflist({'nr': '$'}).nr)
  silent colder
  call assert_equal('other', getqflist({'title': 1}).title)
endfunction

function! s:test_a_name_is_saved_again() abort
  call s:list()
  silent QfSave wip
  call setqflist([], ' ', {'title': 'Pruned', 'items': [{'filename': s:repo . '/b.py', 'lnum': 1}]})
  silent QfSave wip
  silent QfLoad wip
  call assert_equal('Pruned', getqflist({'title': 1}).title)
endfunction

function! s:test_names_complete() abort
  call s:list()
  silent QfSave wip
  silent QfSave work
  call assert_equal(['wip', 'work'], qf_tools#save#complete('w', '', 0))
  call assert_equal(['wip'], qf_tools#save#complete('wi', '', 0))
endfunction

function! s:test_save_and_load_a_path() abort
  call s:list()
  let l:file = s:tmp . '/kept.json'
  execute 'silent QfSave' fnameescape(l:file)
  " Absolute paths in a save to a path
  call assert_match('"filename":"' . escape(s:repo, '/') . '/tests/a.py"', readfile(l:file)[0])
  execute 'cd' fnameescape(s:tmp)
  execute 'silent QfLoad' fnameescape(l:file)
  let l:items = getqflist()
  call assert_equal(s:repo . '/tests/a.py', fnamemodify(bufname(l:items[0].bufnr), ':p'))
endfunction

function! s:test_a_path_is_kept_without_bang() abort
  call s:list()
  let l:file = s:tmp . '/kept.json'
  call writefile(['mine'], l:file)
  call assert_match('exists (add ! to overwrite)', s:message('QfSave ' . fnameescape(l:file)))
  call assert_equal(['mine'], readfile(l:file))
  execute 'silent QfSave!' fnameescape(l:file)
  call assert_match('qf_tools', readfile(l:file)[0])
endfunction

function! s:test_context_not_json_is_left_out() abort
  call setqflist([], ' ', {'title': 'F', 'context': {'f': function('tr')}, 'items': [
        \ {'filename': s:repo . '/b.py', 'lnum': 1}]})
  call assert_match('1 context(s) not JSON, left out', s:message('QfSave wip'))
  silent QfLoad wip
  call assert_equal('F', getqflist({'title': 1}).title)
  call assert_equal(1, len(getqflist()))
endfunction

function! s:test_load_errors() abort
  call assert_match('no saved list nope', s:message('QfLoad nope'))
  call writefile(['{}'], s:tmp . '/other.json')
  call assert_match('is not a list :QfSave wrote', s:message('QfLoad ' . fnameescape(s:tmp . '/other.json')))
endfunction

function! s:test_a_name_needs_vim_place() abort
  let l:rtp = &runtimepath
  execute 'set runtimepath-=' . fnameescape(s:place)
  try
    call assert_match('needs vim-place', s:message('QfSave wip'))
    call assert_match('needs vim-place', s:message('QfLoad wip'))
  finally
    let &runtimepath = l:rtp
  endtry
endfunction

let s:failed = 0
let s:prefix = expand('<SID>') . 'test_'
let s:names = []
for s:line in split(execute('function'), "\n")
  if stridx(s:line, 'function ' . s:prefix) == 0
    call add(s:names, matchstr(s:line, '^function \zs[^(]\+'))
  endif
endfor
for s:name in s:names
  let s:label = matchstr(s:name, 'test_\zs\w\+')
  if !empty($TEST) && s:label !~# $TEST
    continue
  endif
  call s:reset()
  let v:errors = []
  try
    call call(s:name, [])
  catch
    call add(v:errors, v:exception . ' @ ' . v:throwpoint)
  endtry
  if empty(v:errors)
    call add(s:out, 'ok   ' . s:label)
  else
    let s:failed += 1
    call add(s:out, 'FAIL ' . s:label)
    call extend(s:out, map(copy(v:errors), '"     " . v:val'))
  endif
endfor
call add(s:out, s:failed ? s:failed . ' failed' : 'all passed')
call writefile(s:out, '/dev/stdout')
call delete(s:tmp, 'rf')
execute 'cquit' (s:failed ? 1 : 0)
