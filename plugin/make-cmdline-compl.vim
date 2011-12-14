" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


function! MakeCmdlineComplete(arglead, cmdline, cursorpos)
    try
        let cands = s:parse_makefile()
        return a:arglead !=# '' ?
        \           filter(cands, 'stridx(v:val, a:arglead) is 0') :
        \           cands
    catch
        return []
    endtry
endfunction

function! s:parse_makefile()
    try   | let lines = readfile(s:get_makefile())
    catch | return [] | endtry

    " TODO: More strictly?
    let rx = '^[^:]\+\ze:'
    return filter(map(lines, 'matchstr(v:val, rx)'), 'v:val !=# ""')
endfunction

let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && (has('mac') || has('macunix') || has('gui_macvim') || system('uname') =~? '^darwin')
if s:is_windows || s:is_cygwin || s:is_mac
    " Case in filepath is ignored.
    function! s:get_makefile()
        return filereadable('Makefile') ?
        \           'Makefile' :
        \           ''
    endfunction
else
    " Case in filepath is not ignored.
    function! s:get_makefile()
        return filereadable('Makefile') ?
        \           'Makefile' :
        \      filereadable('makefile') ?
        \           'makefile' :
        \           ''
    endfunction
endif


command! -bang -nargs=* -complete=customlist,MakeCmdlineComplete
\           Make  make<bang>  <args>
command! -bang -nargs=* -complete=customlist,MakeCmdlineComplete
\           LMake lmake<bang> <args>

" Replace builtin Ex commands using altercmd.vim
" if altercmd.vim was installed.
if globpath(&rtp, 'autoload/altercmd.vim') != ''
    call altercmd#load()
    AlterCommand mak[e] Make
    AlterCommand lmak[e] LMake
endif


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
