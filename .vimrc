scriptencoding utf-8
set encoding=utf-8
set nocompatible
" Remove all autocommands in case we are reloading this file
au!

execute pathogen#infect()

" =============================================== "
"                 Display options                 "
" =============================================== "

colorscheme apprentice
if has("gui_win32")
    set guifont=Consolas:h11
endif

" Invisible characters
set list
set listchars=tab:»\ ,trail:·,extends:>,nbsp:.

if !has("win32")
    " Indicator of wrapping text; default Windows fonts don't have a nice
    " glyph for this.
    set showbreak=↪
endif

" Remove toolbar
set guioptions-=T
" Show cursor coordinates
set ruler
" Syntax
syntax enable
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
autocmd GUIEnter * set visualbell t_vb=

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

" Location for backup files. Note the double slash to avoid name collisions.
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" Tabs
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase



" =============================================== "
"                 Key bindings                    "
" =============================================== "

" General key mappings
let mapleader=" "

" Move through wrapped lines unless the command is given a count
nnoremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

nnoremap <silent> <leader>w :bd<CR>
nnoremap <silent> <leader>h :noh<CR>
nnoremap <silent> <leader>ca :call <SID>ToggleFlag('formatoptions', 'a')<CR>

" CD to the directory of current file
nnoremap <leader>cd :cd %:p:h<CR>

" Buffer navigation
nnoremap <M-[> :bprev<CR>
nnoremap <M-]> :bnext<CR>

" Windows navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h


" Filetype settings {{{
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd FileType markdown
  \ setlocal spell textwidth=78 formatoptions+=a |
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

" Firefox extensions install manifest
autocmd FileType rdf set filetype=xml

" help windows
autocmd FileType help setlocal nospell
" }}}

" Pretty print JSON (whole file or range)
let g:python_exe = 'python'
command! -range=% JsonFormat exe '<line1>,<line2>!' . g:python_exe . ' -m json.tool'

" When editing a file, jump to the last known cursor position.
autocmd BufWinEnter *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" Strip trailing whitespace on save
function! <SID>StripTrailingWhitespace()
    if exists('b:noStripWhitespace')
        return
    endif
    " save last search and cursor position
    let s = @/
    let l = line(".")
    let c = col(".")
    " strip the whitespace
    %s/\s\+$//e
    " restore search history and cursor position
    let @/ = s
    call cursor(l, c)
endfun
autocmd BufWritePre * call <SID>StripTrailingWhitespace()

" Session
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winpos,winsize
command! SaveProject exe "mksession! " . v:this_session
function! ListProjects(ArgLead, CmdLine, CursorPos)
    let project_ext = '.vimsession'
    let session_files = globpath(g:my_projects_dir, '*' . project_ext)
    " echo session_files
    return session_files
endfun
command! -nargs=1 -complete=custom,ListProjects LoadProject source <args>


function! <SID>ToggleFlag(option, flag)
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
"   bring up 'goto definition' dialog; faster than CtrlPTag (see below), but more false positives
nnoremap <leader>cg :cs find g<Space>

nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
" }}}

" Plugin settings {{{

" fswitch settings
nnoremap <silent> <leader>f :FSHere<CR>

" buftabline settings
let g:buftabline_show=1    " show only if at least 2 buffers
let g:buftabline_numbers=1 " display buffer numbers
"call buftabline#update(0)  " reload buftabline settings when reloading .vimrc

" CtrlP settings
"   max height of match window
let g:ctrlp_match_window = 'max:20'
"   search only by filename, instead of filename and path; can be toggled with <c-d>
let g:ctrlp_by_filename = 1
"   don't update file list on every keypress
let g:ctrlp_lazy_update = 1
"   allow jumping to tag
let g:ctrlp_extensions = ['tag']
nnoremap <leader>t :CtrlPTag<CR>
"   buffer list
nnoremap <leader>b :CtrlPBuffer<CR>
"   ignore patterns, only used if ctrlp_user_command is not used
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
let g:ctrlp_user_command = {
  \ 'types': {
      \ 1: ['.git', 'cd %s && git ls-files -co --exclude-standard'],
  \ }
  \ }

" }}}

" vim:foldmethod=marker

