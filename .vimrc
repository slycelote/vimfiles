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

autocmd vimrc ColorScheme apprentice call s:TweakApprenticeColors()
function! s:TweakApprenticeColors() abort
    set background=dark
    highlight Comment guifg=#686868
    highlight FoldColumn guifg=#444444
    highlight CursorLine guibg=#404040
    " highlight ModeMsg cterm=NONE gui=NONE
endfunction

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
set sidescroll=1 " Sensible scrolling when no wrapping
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
set sessionoptions=blank,buffers,curdir,folds,help,resize,tabpages,winpos,winsize
set mousemodel=popup_setpos " Intuitive behavior for right click

if executable('rg')
  set grepprg=rg\ --vimgrep\ --color\ never\ --smart-case\ $*
  set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')
  set grepprg=ag\ --vimgrep\ $*
  set grepformat^=%f:%l:%c:%m   " file:line:column:message
endif



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
nnoremap <expr> <CR> empty(&buftype) ? ':bnext<CR>' : '<CR>'
nnoremap <BS> :bprev<CR>

" Windows navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" remap for normal mode in cyrillic layout
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz


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

    autocmd FileType yaml setlocal softtabstop=2 shiftwidth=2
    autocmd FileType json setlocal softtabstop=2 shiftwidth=2 foldmethod=syntax
    autocmd FileType text setlocal spell textwidth=78
    autocmd FileType vim  setlocal foldmethod=marker
    autocmd FileType gitcommit setlocal spell
    autocmd FileType cpp    setlocal commentstring=//\ %s
    autocmd FileType cmake  setlocal commentstring=#\ %s
    autocmd FileType nasm   setlocal commentstring=;\ %s

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

" }}}

" vim:foldmethod=marker

