scriptencoding utf-8
set encoding=utf-8

set nocompatible
let g:pathogen_disabled = []
execute pathogen#infect()

" Remove toolbar
set guioptions-=T

" Visuals
let g:solarized_termcolors=256
set t_Co=256
set background=dark
colorscheme solarized
if has("gui_win32")
    set guifont=Consolas:h11:cANSI
endif

" Invisible characters
set list
set listchars=tab:»\ ,trail:·,extends:>,nbsp:.

" Syntax
syntax on
" Show line numbers
set number

" Location for backup files. Note the double slash to avoid name collisions.
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" Enable filetype detection and filetype-specific plugins and indentation rules
filetype plugin indent on
" When a file was changed outside of vim and not changed in vim, reread it
set autoread

" Tabs
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab

" Intuitive backspace behavior
set backspace=indent,eol,start

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Allow switching to another buffer without saving
set hidden

" List completion
set wildmode=longest:list,full

" General key mappings
let mapleader=" "
nnoremap j gj
nnoremap k gk
nnoremap <leader>q :bd<CR>
nnoremap <leader>h :noh<CR>
" CD to the directory of current file
nnoremap <leader>cd :cd %:p:h<CR>


" Windows movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" Filetype settings {{{
" Markdown file type
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd FileType markdown
  \ setlocal spell |
  \ setlocal textwidth=78 |
  \ setlocal formatoptions+=a |
  \ let b:noStripWhitespace=1

" vim file type
autocmd FileType vim let b:noStripWhitespace=1

" text file type
autocmd FileType text setlocal textwidth=78
" }}}

" Pretty print JSON (whole file or range)
let g:python_exe = 'python'
command! -range=% JsonPrettify exe '<line1>,<line2>!' . g:python_exe . ' -m json.tool'

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


" cscope and ctags {{{
"   search tags file in the directory of current file and upwards to root
set tags=./tags;
"   use both ctags and cscope for definition searches
set cst
"   prefer ctags to cscope
set csto=1
"   bring up 'goto definition' dialog; faster than CtrlPTag (see below), but more false positives
nnoremap <leader>cg :cs find g<Space>

nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
" }}}

" Plugin settings {{{

" buftabline settings
let g:buftabline_show=1    " show only if at least 2 buffers
let g:buftabline_numbers=1 " display buffer numbers
"call buftabline#update(0)  " reload buftabline settings when reloading .vimrc

" CtrlP settings
"   search only by filename, instead of filename and path; can be toggled with <c-d>
let g:ctrlp_by_filename = 1
"   don't update file list on every keypress
let g:ctrlp_lazy_update = 1
"   allow jumping to tag
let g:ctrlp_extensions = ['tag']
nnoremap <leader>t :CtrlPTag<CR>
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

