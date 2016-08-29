" Require Plugins:
" Pathogen
" https://github.com/ctrlpvim/ctrlp.vim.git
" https://github.com/vim-airline/vim-airline.git
" https://github.com/vim-airline/vim-airline-themes.git
" https://github.com/mhinz/vim-startify.git
" https://github.com/scrooloose/nerdtree.git
" https://github.com/tpope/vim-surround.git
" https://github.com/scrooloose/syntastic.git
" https://github.com/godlygeek/tabular.git
" https://github.com/tpope/vim-unimpaired.git
" https://github.com/qpkorr/vim-bufkill.git
" https://github.com/tpope/vim-unimpaired.git
" https://github.com/qpkorr/vim-bufkill.git
" https://github.com/FooSoft/vim-argwrap

" Window Size
set lines=80 columns=150

"Personal Settings.
"More to be added soon.
set nocompatible
execute pathogen#infect()
filetype plugin indent on
syntax on
"Set the status line options. Make it show more information.
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}
"Set Color Scheme and Font Options
colorscheme monokai
set guifont=Consolas:h10
"set line no, buffer, search, highlight, autoindent and more.
set hidden

" Ignore case, unless the search contains a capital letter
set ignorecase
set smartcase

set incsearch
set hlsearch
set showmatch
set cindent
set ruler                       " Enable row/column in bottom left
set noerrorbells
set viminfo+=n$VIM/_viminfo
set showcmd
set mouse=a
set history=1000
set undolevels=1000

" Stop Flashing people
set vb t_vb=

" Line Numbers
set relativenumber
set number

" Tab Settings for 4 spaces = tab ( use this for work )
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
" Tab settings 1 tab = 1 tab character ( appears as 4 spaces wide ) ( use this
" for pleasure )
" set tabstop=4 softtabstop=0 noexpandtab shiftwidth=4

" Wrap it up boy
set wrap
set textwidth=80
set linebreak
set wrapmargin=0
set formatoptions=cqt

" Set Mapleader
let mapleader="\<Space>"

" Buffer Navigation ( tired of this :bp shit )
nnoremap <silent> <F11> :bp<CR>
nnoremap <silent> <F12> :bn<CR>
inoremap <silent> <F11> <ESC>:bp<CR>i
inoremap <silent> <F12> <ESC>:bn<CR>i

" Training Wheels ( disable arrow keys )
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap Y y$
nnoremap <silent> <Leader>s mp:%s/\v\s+$//<CR>:nohl<CR>`p
nnoremap <Leader>w :w<CR>
nnoremap <Leader>nh :nohl<CR>
inoremap <C-i> <ESC>

" Swap and Backup files
set nobackup
set noswapfile

" Note Header shortuct
nnoremap <Leader>3 080i#<ESC>a<CR>#<Space>

" I like folding Markers
set foldmethod=marker

" Stolen from Example vimrc
" Only do this part when compiled with support for autocommands.
if has("autocmd")
    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
        au!

        " For all text files set 'textwidth' to 78 characters.
        autocmd FileType text setlocal textwidth=78

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        " Also don't do it when the mark is in the first line, that is the default
        " position when opening a file.
        autocmd BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif

    augroup END
else
    set autoindent		" always set autoindenting on
endif " has("autocmd")

" CtrlP Options
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$',
  \ 'file': '\v\.(exe|so|dll|meta|csproj|sln|manifest|suo|pdb|user|jmconfig)$'
  \ }

" Airline Config
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'molokai'

" NERDTree
nnoremap <silent> <F1> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.meta$']

" vim-startify
let g:startify_session_delete_buffers = 1    " Delete Opened buffers for changing sessions
let g:startify_session_persistence    = 1    " Save Current Session on close/switch
let g:startify_enable_special         = 0    " Don't show the empty buffer and quit options on start screen
let g:startify_list_order             = [ 'sessions', 'files', 'bookmarks', 'dir' ]

" Dumb function to center RMS's fat head
function! s:filter_header(lines) abort
    let longest_line   = max(map(copy(a:lines), 'len(v:val)'))
    let centered_lines = map(copy(a:lines),
        \ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
    return centered_lines
endfunction

let g:startify_custom_header = s:filter_header([
    \ '                                                ',
    \ '                  @@@@@@ @                      ',
    \ '                 @@@@     @@                    ',
    \ '                @@@@ =   =  @@                  ',
    \ '               @@@ @ _   _   @@                 ',
    \ '               @@@ @(0)|(0)  @@                 ',
    \ '              @@@@   ~ | ~   @@                 ',
    \ '              @@@ @  (o1o)    @@                ',
    \ '             @@@    #######    @                ',
    \ '             @@@   ##{+++}##   @@               ',
    \ '            @@@@@ ## ##### ## @@@@              ',
    \ '            @@@@@#############@@@@              ',
    \ '           @@@@@@@###########@@@@@@             ',
    \ '          @@@@@@@#############@@@@@             ',
    \ '          @@@@@@@### ## ### ###@@@@             ',
    \ '           @ @  @              @  @             ',
    \ '             @                    @             ',
    \ '                                                ',
    \ 'Me Mo Mo Richard Stallman, Welcome to the EMACS!',
    \ '',
    \ ] )

" Startify Alias
nmap <Leader>p :SLoad<Space>

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

" Javascript Syntax Checker
let g:syntastic_javascript_checkers = ['jsxhint']
" Requires curl to be installed
let g:syntastic_html_checkers = ['w3']

" Tabularize shortcuts
" Shortcut for tabularize json colon allignement
nmap <leader>tj viB:Tabularize /:<CR>
nmap <silent> <leader>t= viB:Tabularize /=<CR>

" ArgWrap
nnoremap <silent> <leader>a :ArgWrap<CR>

" CSharp Folding? Hopefully?
" TODO: ftplugin folders for this kind of shit
if !exists("autocommands_csharp")
	let autocommands_csharp = 1

	"setup folding for CSharpy
	autocmd BufNewFile,BufRead *.cs setlocal foldmethod=syntax
endif
