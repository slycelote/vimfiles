scriptencoding utf-8
set encoding=utf-8
augroup vimrc
    " Remove all autocommands in case we are reloading this file
    autocmd!
augroup END

execute pathogen#infect()

silent! packadd cfilter

" https://gist.github.com/romainl/4df4cde3498fada91032858d7af213c2
if !exists('g:env')
    if has('win64') || has('win32') || has('win16')
        let g:env = 'WINDOWS'
    else
        let g:env = toupper(substitute(system('uname'), '\n', '', ''))
    endif
endif

" =============================================== "
"                 Display options                 "
" =============================================== "

colorscheme apprentice

if has('gui') && g:env =~ 'WINDOWS'
    set guifont=Consolas:h11
endif

" Invisible characters
set list
set listchars=tab:»\ ,trail:·,extends:>,nbsp:.

if g:env !~ 'WINDOWS'
    " Indicator of wrapping text; default Windows fonts don't have a nice glyph for this.
    set showbreak=↪
endif

set guioptions-=T " Remove toolbar
set ruler " Show cursor coordinates
if !exists("g:syntax_on")
    syntax enable
endif
set number " Show line numbers
" In case the last line of the window is long, display as much of it as possible
" instead of '@' characters
set display+=lastline
set cursorline " Highlight current line
set guicursor+=a:blinkon0 " Disable cursor blinking


" =============================================== "
"            Behaviour/misc options               "
" =============================================== "

" Disable beeping and flashing
set noerrorbells visualbell t_vb=
autocmd vimrc GUIEnter * set visualbell t_vb=

" Enable filetype detection and filetype-specific plugins and indentation rules
filetype plugin indent on
set autoindent

set hidden " Allow switching to another buffer without saving
set backspace=indent,eol,start " Intuitive backspace behavior
set autoread " When a file was changed outside of vim and not changed in vim, reread it
set nomodeline " Don't use 'magic vim comments'
set showcmd " Show partial commands as you type
set showmatch " Briefly show matching brackets in insert mode
set lazyredraw " Don't redraw screen while executing macros
set sidescroll=1 " 'Smooth' horizontal scrolling
set history=1000 " Keep longer history of ":" commands
"set viminfo='100,f1,<100,:100,h,% " At startup, restore buffer list and some history
set nrformats-=octal " Do not recognize octal numbers for Ctrl-A and Ctrl-X
set formatoptions+=j " Delete comment character when joining commented lines

" On the first tab press, display list and complete longest prefix;
" on the second tab, display menu completion
set wildmode=list:longest,full
set wildmenu

set foldcolumn=1
set foldlevelstart=99 " start with all folds open

" https://stackoverflow.com/a/18734557
let s:vim_config_dir_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
" Location for backup files. Note the double slash to avoid name collisions.
let &backupdir=s:vim_config_dir_path.'/backup//'
let &directory=s:vim_config_dir_path.'/swap//'
let &undodir=s:vim_config_dir_path.'/undo//'

" Tabs
set tabstop=8
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

set infercase " Be smart in completion despite ignorecase
set foldopen-=block " Don't open folds on { and } commands
" What to save in session files
set sessionoptions-=options
set sessionoptions+=winpos,resize
set mousemodel=popup_setpos " Intuitive behavior for right click

if executable('rg')
  set grepprg=rg\ --vimgrep\ --color\ never\ --smart-case\ $*
  set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')
  set grepprg=ag\ --vimgrep\ $*
  set grepformat^=%f:%l:%c:%m   " file:line:column:message
endif

augroup vimrc
    " Open quickfix window automatically after relevant commands.
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
    " Automatically close corresponding loclist when quitting a window.
    autocmd QuitPre * if &filetype != 'qf' | silent! lclose | endif
augroup END


" =============================================== "
"                 Key bindings                    "
" =============================================== "

let mapleader=" "

inoremap jk <esc>
inoremap jK <esc>
inoremap Jk <esc>
inoremap JK <esc>

" Move through wrapped lines unless the command is given a count
nnoremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Don't display grep output and prompt to hit Return, just bring up quickfix list.
nnoremap <leader>g :silent grep<space>

nnoremap <Leader>cc :cclose<CR>

nnoremap <silent> <leader>w :bd<CR>
nnoremap <silent> <leader>h :noh<CR>
nnoremap <silent> <leader>ca :call s:ToggleFlag('formatoptions', 'a')<CR>

" CD to the directory of current file
nnoremap <leader>cd :cd %:p:h<CR>
" Open the directory of current file
nnoremap <silent> - :Explore<CR>

" Buffer navigation
" The empty check is to ensure that you can still use the enter key in Quickfix windows as you would normally.
nnoremap <expr> <silent> <CR> &buflisted ? ':bnext<CR>' : '<CR>'
nnoremap <silent> <BS> :bprev<CR>

" Windows navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" gdb settings {{{
if executable('gdb')
    let g:termdebug_wide=1
    packadd termdebug
    nnoremap <C-F5> :Run<CR>
    nnoremap <F5> :Continue<CR>
    nnoremap <S-F5> :call TermDebugSendCommand("set confirm off\nquit")<CR>
    nnoremap <F9> :Break<CR>
    nnoremap <S-F9> :Clear<CR>
    nnoremap <F10> :Over<CR>
    nnoremap <C-F10> :call TermDebugSendCommand("advance -source " . expand("%:p") . " -line " . line("."))<CR>
    nnoremap <F11> :Step<CR>
    nnoremap <S-F11> :Finish<CR>

    command! -nargs=* SGdb :call TermDebugSendCommand(<q-args>)
    nnoremap <Leader>d :SGdb<Space>
endif

" }}}


" Filetype settings {{{
augroup vimrc
    autocmd BufRead,BufNewFile *.tsv setlocal noexpandtab
    autocmd BufRead,BufNewFile *.xaml set filetype=xml

    autocmd BufRead,BufNewFile *.reminders set filetype=remind
    autocmd FileType remind setlocal commentstring=#\ %s

    autocmd BufRead,BufNewFile *.gv set filetype=dot
    autocmd FileType dot    setlocal commentstring=//\ %s

    autocmd BufRead,BufNewFile *.md set filetype=markdown
    autocmd FileType markdown
      \ setlocal spell textwidth=78 |
      \ let b:noStripWhitespace=1

    autocmd BufRead,BufNewFile *.adoc set filetype=asciidoc
    autocmd FileType asciidoc
      \ setlocal spell textwidth=78 formatoptions+=n
      \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
      \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>

    autocmd BufRead,BufNewFile .ansible-lint set filetype=yaml
    autocmd FileType yaml setlocal softtabstop=2 shiftwidth=2

    autocmd FileType json setlocal softtabstop=2 shiftwidth=2 foldmethod=syntax
    autocmd FileType text setlocal spell textwidth=78
    autocmd FileType vim  setlocal foldmethod=marker
    autocmd FileType gitcommit setlocal spell
    autocmd FileType cpp    setlocal commentstring=//\ %s
    autocmd FileType cmake  setlocal commentstring=#\ %s
    autocmd FileType nasm   setlocal commentstring=;\ %s
    autocmd FileType inform setlocal commentstring=\!\ %s suffixesadd+=.h |
        \ syn keyword informLibVariable  lookmode
    autocmd FileType haskell setlocal suffixesadd=.hs includeexpr=substitute(v:fname,'\\.','/','g') include=^import\\s*\\(qualified\\)\\?\\s*
    autocmd FileType cabal  setlocal commentstring=--\ %s
    autocmd FileType smt2   setlocal commentstring=;\ %s
    autocmd FileType sh,bash setlocal isfname+=^= softtabstop=2 shiftwidth=2
    autocmd FileType fish setlocal iskeyword-=/
    autocmd FileType ledger setlocal commentstring=;\ %s
    " \n at end of file in a mustache partial leads to a \n in the primary template
    autocmd BufRead,BufNewFile *.mustache setlocal noeol nofixeol

    " help windows
    autocmd FileType help setlocal nospell nonumber norelativenumber
    " quickfix window
    autocmd FileType qf setlocal nospell norelativenumber nobuflisted
augroup END
" }}}

" Pretty print JSON (whole file or range)
let g:python_exe = 'python'
command! -range=% JsonFormat exe '<line1>,<line2>!' . g:python_exe . ' -m json.tool'

" Save current view settings on a per-window, per-buffer basis.
function! s:AutoSaveWinView() abort
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! s:AutoRestoreWinView() abort
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

let g:no_jump_last_filetype = "gitcommit,gitrebase,svn,hgcommit"
let g:no_jump_last_buftype = "quickfix,nofile,help"

" Jump to the last known cursor position. See :h last-position-jump and vim-lastplace plugin.
function! s:AutoJumpToLastPosition() abort
    if index(split(g:no_jump_last_buftype, ","), &buftype) != -1
        return
    endif

    if index(split(g:no_jump_last_filetype, ","), &filetype) != -1
        return
    endif

    if line("'\"") > 0 && line("'\"") <= line("$")
        execute "normal! g`\""
    endif
endfunction

augroup vimrc
    autocmd BufReadPost * call s:AutoJumpToLastPosition()
    " Keep window position when switching buffers.
    autocmd BufLeave * call s:AutoSaveWinView()
    autocmd BufEnter * call s:AutoRestoreWinView()
augroup END

" Strip trailing whitespace on save
function! s:StripTrailingWhitespace() abort
    if exists('b:noStripWhitespace')
        return
    endif
    let l:saved_winview = winsaveview()
    keeppatterns %s/\v\s+$//e
    call winrestview(l:saved_winview)
endfun
autocmd vimrc BufWritePre * call s:StripTrailingWhitespace()

function! s:ToggleFlag(option, flag) abort
    exec ('let lopt = &' . a:option)
    if lopt =~ (".*" . a:flag . ".*")
        exec 'setlocal' (a:option . '-=' . a:flag)
    else
        exec 'setlocal' (a:option . '+=' . a:flag)
    endif
endfunction

" SmartCloseBuffer {{{
" Close current buffer, current window, or both, depending on what makes more
" sense. Try not to destroy window layout.
nnoremap <expr> <leader>w <SID>SmartCloseBuffer()

" Checks if the buffer's windows are typically 'transient' and can be safely
" closed. (E.g., quickfix or location list.)
function! s:IsTransientBuffer(buf) abort
    let buftype = getbufvar(a:buf, '&buftype')
    return !empty(buftype)
endfunction

" When closing the buffer but not the window, another 'interesting' buffer
" will be displayed in the window.
function! s:IsInterestingBuffer(buf) abort
    return buflisted(a:buf) && !s:IsTransientBuffer(a:buf)
endfunction

function! s:SmartCloseBuffer() abort
    let win = win_getid()
    let buf = winbufnr(win)
    if s:IsTransientBuffer(buf)
        return ":bd\n"
    endif

    let tab = win_id2tabwin(win)[0]
    let buf_windows = win_findbuf(buf)
    let tab_window_buffers = tabpagebuflist(tab)
    let is_displayed_in_other_windows = len(buf_windows) > 1

    if !is_displayed_in_other_windows && len(tab_window_buffers) <= 1
        " Delete the buffer and close the window. If there are multiple open
        " tabs, the current one will be closed.
        return ":bd\n"
    endif

    " The buffer is displayed in multiple windows, or current tab has
    " multiple windows. We don't want to destroy window layout.
    let all_buffers = filter(range(1, bufnr('$')), 'v:val != buf && s:IsInterestingBuffer(v:val)')
    let buffers_not_displayed_in_tab = filter(copy(all_buffers), 'index(tab_window_buffers, v:val) == -1')
    if !empty(buffers_not_displayed_in_tab)
        let candidates = buffers_not_displayed_in_tab
    elseif !empty(all_buffers)
        let candidates = all_buffers
    else
        " Current tab (and other tabs, if any) displays one or more views of the only interesting buffer,
        " and also (potentially) non-interesting buffers.
        " TODO: what to do here?
        "
        " Close current view (and delete the buffer if it's possible to keep
        " window layout in other tabs.)
        " let is_displayed_in_other_tabs = !empty(filter(buf_windows, 'win_id2tabwin(v:val)[0] != tab'))
        " return is_displayed_in_other_tabs ? "<C-W>c" : ":bd\n"
        "
        return is_displayed_in_other_windows ? "<C-W>c" : ":bd\n"
    endif

    " Try alternate buffer first, otherwise arbitrary candidate.
    let another_buf = bufnr('#')
    if index(candidates, another_buf) == -1
        let another_buf = candidates[0]
    endif

    " Switch to another interesting buffer.
    let res = ":b" . string(another_buf)
    if !is_displayed_in_other_windows
        " We can delete the buffer without destroying window layout.
        let res .= "|bd#"
    endif
    let res .= "\n"
    return res
endfunction
" }}}

" cscope and ctags {{{

set tags=./tags; " search tags file in the directory of current file and upwards to root
set cscopetag " use both ctags and cscope for definition searches
set cscopetagorder=1 " prefer ctags to cscope
set cscopequickfix=s-,c-,d-,i-,t-,e- " open quickfix window with cscope results

"   bring up 'goto definition' dialog
nnoremap <leader>cg :cs find g<Space>
"   :help cscope-suggestions
nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
" }}}

" Plugin settings {{{

" fswitch settings
nnoremap <silent> <leader>f :FSHere<CR>
augroup vimrc
    autocmd BufEnter *.in  let b:fswitchdst = 'out' | let b:fswitchlocs = '.'
    autocmd BufEnter *.out let b:fswitchdst = 'in'  | let b:fswitchlocs = '.'
augroup END

" buftabline settings
let g:buftabline_show=1    " show only if at least 2 buffers
let g:buftabline_numbers=1 " display buffer numbers
silent! call buftabline#update(0)  " reload buftabline settings when reloading .vimrc

" obsession settings
augroup vimrc
    autocmd User ObsessionPre let g:obsession_append = ['set path='.&path]
augroup END

" }}}

" vim:foldmethod=marker

