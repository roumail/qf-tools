" :QfSave / :QfLoad: the quickfix list to a file and back, with its title,
" its context and its entries' user_data, so a plugin's list works as it did

let s:version = 1

function! s:error(msg) abort
  echohl ErrorMsg
  echomsg 'qf-tools: ' . a:msg
  echohl None
endfunction

" A path has a / or starts with ~ or .; anything else is a name, kept where
" vim-place keeps plugins' files
function! s:is_path(arg) abort
  return a:arg =~# '/' || a:arg =~# '^[~.]'
endfunction

function! s:has_place() abort
  return !empty(globpath(&runtimepath, 'autoload/roumail_place.vim', 1))
endfunction

" The file for arg, and the directory its entries' paths are relative to
" ('' for absolute paths); [] after an error
function! s:target(what, arg) abort
  if empty(a:arg)
    call s:error(a:what . ' needs a name, or a path')
    return []
  elseif s:is_path(a:arg)
    return [fnamemodify(expand(a:arg), ':p'), '']
  elseif !s:has_place()
    call s:error(a:what . ' of a name needs vim-place (with vim-fugitive), which is not installed;'
          \ . ' give a path (./' . a:arg . '.json)')
    return []
  endif
  return [roumail_place#dir('qf-tools') . '/' . a:arg . '.json', roumail_place#get().dir]
endfunction

" value if it can be written as JSON, else v:null
function! s:jsonable(value) abort
  try
    call json_encode(a:value)
    return a:value
  catch
    return v:null
  endtry
endfunction

function! qf_tools#save#save(bang, arg) abort
  let l:target = s:target(':QfSave', a:arg)
  if empty(l:target)
    return
  endif
  let [l:file, l:root] = l:target
  if s:is_path(a:arg) && filereadable(l:file) && !a:bang
    call s:error(fnamemodify(l:file, ':~') . ' exists (add ! to overwrite)')
    return
  endif
  let l:list = getqflist({'title': 1, 'context': 0, 'items': 1})
  let l:dropped = 0
  let l:items = []
  for l:item in l:list.items
    let l:entry = copy(l:item)
    call remove(l:entry, 'bufnr')
    if l:item.bufnr
      let l:name = bufname(l:item.bufnr)
      " A buffer of a plugin's (fugitive://) is kept as named
      let l:name = l:name =~# '^\a\+://' ? l:name : fnamemodify(l:name, ':p')
      if !empty(l:root) && stridx(l:name, l:root . '/') == 0
        let l:name = strpart(l:name, len(l:root) + 1)
      endif
      let l:entry.filename = l:name
    endif
    if has_key(l:entry, 'user_data')
      let l:data = s:jsonable(l:entry.user_data)
      if l:data is v:null && l:entry.user_data isnot v:null && !empty(l:entry.user_data)
        let l:dropped += 1
      endif
      let l:entry.user_data = l:data is v:null ? '' : l:data
    endif
    call add(l:items, l:entry)
  endfor
  let l:context = s:jsonable(l:list.context)
  if l:context is v:null && !empty(l:list.context)
    let l:dropped += 1
  endif
  call mkdir(fnamemodify(l:file, ':h'), 'p')
  let l:json = json_encode({'qf_tools': s:version, 'title': l:list.title,
        \ 'context': l:context is v:null ? '' : l:context, 'items': l:items})
  if writefile([l:json], l:file) != 0
    call s:error('cannot write ' . fnamemodify(l:file, ':~'))
    return
  endif
  echo 'QfSave: ' . len(l:items) . ' entries to ' . (s:is_path(a:arg) ? fnamemodify(l:file, ':~') : a:arg)
        \ . (l:dropped ? ' (' . l:dropped . ' context(s) not JSON, left out)' : '')
endfunction

function! qf_tools#save#load(arg) abort
  let l:target = s:target(':QfLoad', a:arg)
  if empty(l:target)
    return
  endif
  let [l:file, l:root] = l:target
  if !filereadable(l:file)
    call s:error('no ' . (s:is_path(a:arg) ? fnamemodify(l:file, ':~') : 'saved list ' . a:arg))
    return
  endif
  try
    let l:saved = json_decode(join(readfile(l:file), "\n"))
  catch
    let l:saved = {}
  endtry
  if type(l:saved) != v:t_dict || !has_key(l:saved, 'qf_tools')
    call s:error(fnamemodify(l:file, ':~') . ' is not a list :QfSave wrote')
    return
  endif
  let l:items = l:saved.items
  for l:item in l:items
    if has_key(l:item, 'filename') && !empty(l:root)
          \ && l:item.filename !~# '^/\|^\a\+://'
      let l:item.filename = l:root . '/' . l:item.filename
    endif
  endfor
  " A new list, so :colder goes back to the one before it
  call setqflist([], ' ', {'title': l:saved.title, 'context': l:saved.context, 'items': l:items})
  copen
  echo 'QfLoad: ' . len(l:items) . ' entries from ' . (s:is_path(a:arg) ? fnamemodify(l:file, ':~') : a:arg)
endfunction

" The names saved here, then files
function! qf_tools#save#complete(lead, cmdline, pos) abort
  if s:is_path(a:lead) || !s:has_place()
    return getcompletion(a:lead, 'file')
  endif
  let l:names = map(glob(roumail_place#dir('qf-tools') . '/*.json', 1, 1), 'fnamemodify(v:val, ":t:r")')
  return filter(sort(l:names), 'stridx(v:val, a:lead) == 0')
endfunction
