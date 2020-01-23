scriptencoding utf-8
set encoding=utf-8

augroup vimrc
    " Remove all autocommands in case we are reloading this file
    autocmd!
augroup END

execute pathogen#infect()

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
    " Indicator of wrapping text; default Windows fonts don't have a nice
    " glyph for this.
    set showbreak=↪
endif

" Remove toolbar
set guioptions-=T
" Show cursor coordinates
set ruler
" Syntax
if !exists("g:syntax_on")
    syntax enable
endif
" Show line numbers
set number
" In case the last line of the window is long, display as much of it as possible
" instead of '@' characters
set display+=lastline
" Highlight current line
set cursorline
" Disable cursor blinking
set guicursor+=a:blinkon0



" =============================================== "
"                 Behaviour options               "
" =============================================== "

" Disable beeping and flashing
set noerrorbells visualbell t_vb=
autocmd vimrc GUIEnter * set visualbell t_vb=

" Enable filetype detection and filetype-specific plugins and indentation rules
filetype plugin indent on
set autoindent

" Allow switching to another buffer without saving
set hidden
" Intuitive backspace behavior
set backspace=indent,eol,start
" When a file was changed outside of vim and not changed in vim, reread it
set autoread
" Don't use 'magic vim comments'
set nomodeline
" Show partial commands as you type
set showcmd
" Briefly show matching brackets in insert mode
set showmatch
" Don't redraw screen while executing macros
set lazyredraw
" Sensible scrolling when no wrapping
set sidescroll=1
" At startup, restore buffer list and some history
"set viminfo='100,f1,<100,:100,h,%
" Do not recognize octal numbers for Ctrl-A and Ctrl-X
set nrformats-=octal
" Delete comment character when joining commented lines
set formatoptions+=j

" On the first tab press, display list and complete longest prefix;
" on the second tab, display menu completion
set wildmode=list:longest,full
set wildmenu

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

" Be smart in completion despite ignorecase
set infercase

" Don't open folds on { and } commands
set foldopen-=block

" What to save in session files
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winpos,winsize




" =============================================== "
"                 Key bindings                    "
" =============================================== "

" General key mappings
let mapleader=" "

inoremap jk <esc>
inoremap jK <esc>
inoremap Jk <esc>
inoremap JK <esc>

" Move through wrapped lines unless the command is given a count
nnoremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

nnoremap <silent> <leader>w :bd<CR>
nnoremap <silent> <leader>h :noh<CR>
nnoremap <silent> <leader>ca :call s:ToggleFlag('formatoptions', 'a')<CR>

" CD to the directory of current file
nnoremap <leader>cd :cd %:p:h<CR>
" Open the directory of current file
nnoremap <silent> - :Ex<CR>

" Buffer navigation
" The empty check is to ensure that you can still use the enter key in Quickfix windows as you would normally.
nnoremap <expr> <CR> empty(&buftype) ? ':bnext<CR>' : '<CR>'
nnoremap <BS> :bprev<CR>

" Windows navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h


" Filetype settings {{{
augroup vimrc
    autocmd BufRead,BufNewFile *.md set filetype=markdown
    autocmd BufRead,BufNewFile *.reminders set filetype=remind
    autocmd FileType markdown
      \ setlocal spell textwidth=78 |
      \ let b:noStripWhitespace=1

    autocmd BufRead,BufNewFile *.adoc set filetype=asciidoc
    autocmd FileType asciidoc
      \ setlocal spell textwidth=78 formatoptions+=n
      \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
      \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>

    autocmd FileType yaml setlocal tabstop=2 shiftwidth=2
    autocmd FileType text setlocal spell textwidth=78
    autocmd FileType cpp  setlocal commentstring=//\ %s
    autocmd FileType vim  setlocal foldmethod=marker
    autocmd FileType gitcommit setlocal spell
    autocmd FileType remind setlocal commentstring=#\ %s
    autocmd FileType cmake  setlocal commentstring=#\ %s

    " Firefox extensions install manifest
    autocmd FileType rdf set filetype=xml
    " help windows
    autocmd FileType help setlocal nospell nonumber norelativenumber
    " quickfix window
    autocmd FileType qf setlocal norelativenumber nobuflisted
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

augroup vimrc
    " When opening a file, jump to the last known cursor position.
    autocmd BufReadPost * if &filetype != 'gitcommit' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
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

" cscope and ctags {{{
"   search tags file in the directory of current file and upwards to root
set tags=./tags;
"   use both ctags and cscope for definition searches
set cscopetag
"   prefer ctags to cscope
set cscopetagorder=1
"   open quickfix window with cscope results
set cscopequickfix=s-,c-,d-,i-,t-,e-
"   bring up 'goto definition' dialog
nnoremap <leader>cg :cs find g<Space>

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

" }}}

" vim:foldmethod=marker

