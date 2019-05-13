" Vim Home Directory is different depending on which OS we're in {{{
let g:vimfiles_dir = '~/.vim'
if has('win32')
	let g:vimfiles_dir = '~/vimfiles'
endif
" }}}

" Plug Section {{{
" Vim Files folder location (based off OS)
let autoload_dir = '~/.vim/autoload'

if has('win32')
	let autoload_dir = '~/vimfiles/autoload'
endif

let plugfile = autoload_dir . '/plug.vim'
let plugdownloadLocation = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if empty(glob(plugfile))
	if has('win32')
		" Create Autoload dir
		silent execute '!md ' . autoload_dir
		silent execute '!(New-Object Net.WebClient).DownloadFile(' .  plugdownloadLocation . ', $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( ' . plugfile . '))'
	else
		" Hopefully you have curl
		silent execute '!curl -fLo ' . plugfile . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	endif

	" Run Plug Install asap
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
if has('win32')
	call plug#begin('~/vimfiles/plugged')
else " Mac or unix should be the same
	call plug#begin('~/.vim/plugged')
endif

Plug 'FooSoft/vim-argwrap'
Plug 'OrangeT/vim-csharp'
Plug 'PProvost/vim-ps1'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'flazz/vim-colorschemes'
Plug 'godlygeek/tabular'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'mhinz/vim-startify'
Plug 'pangloss/vim-javascript'
Plug 'qpkorr/vim-bufkill'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'sickill/vim-monokai'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }

" Initialize plugin system
call plug#end()

" Automatically install if any plugins are missing
autocmd VimEnter *
			\  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
			\|   PlugInstall --sync | q
			\| endif

" End of Plug }}}

" Window Size
set lines=80 columns=150

"Personal Settings.
"More to be added soon.
set nocompatible
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

" Enable Backspace
set backspace=indent,eol,start

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

" Line Numbers
set relativenumber
set number

" Tab Settings for 4 spaces = tab ( use this for work )
set tabstop=4 softtabstop=0 shiftwidth=4 noexpandtab copyindent nopreserveindent
" Tab settings 1 tab = 1 tab character ( appears as 4 spaces wide ) ( use this
" for pleasure )
" set tabstop=4 softtabstop=0 noexpandtab shiftwidth=4

" Wrap it up boy
set wrap
" Disable automatic newline insertion after X amount of chars
set textwidth=0
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
" Remove trailing whitespace
nnoremap <silent> <Leader>s mp:%s/\v\s+$//<CR>:nohl<CR>`p
" Save File
nnoremap <silent> <Leader><Leader> :w<CR>
nnoremap <Leader>nh :nohl<CR>

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

" Plugin Configurations {{{

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

" vim-startify {{{
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

" }}}

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
nmap <leader>tj viB:Tabularize /^[^:]*\zs:<CR>
nmap <silent> <leader>t= viB:Tabularize /=<CR>
vmap <silent> <leader>t/ :Tabularize /\/\//l4l1<CR>
vmap <silent> <leader>t= :Tabularize /=<CR>
vmap <silent> <leader>tj :Tabularize /^[^:]*\zs:<CR>

" ArgWrap
nnoremap <silent> <leader>a :ArgWrap<CR>

" Insert DateTime stamp (useful for notes)
nnoremap <leader>dt "=strftime('%c')<CR>gp

" vimwiki/vimwiki {{{
let g:vimwiki_list = [
			\{
			\'path'        : '~/vimwiki/mwl/',
			\'index'       : 'index',
			\'auto_tags'   : 1,
			\'auto_toc'    : 1
			\}
			\]

let g:vimwiki_folding = 'list'

" Header Colors
hi VimwikiHeader1 guifg=#FF0000
hi VimwikiHeader2 guifg=#00FF00
hi VimwikiHeader3 guifg=#0000FF
hi VimwikiHeader4 guifg=#FF00FF
hi VimwikiHeader5 guifg=#00FFFF
hi VimwikiHeader6 guifg=#FFFF00

" VimWiki skeleton file
if has("autocmd")
	augroup wiki_templates
		au!
		if has('win32')
			autocmd BufNewFile *.wiki 0r ~/vimfiles/templates/skeleton.wiki
		else
			autocmd BufNewFile *.wiki 0r ~/.vim/templates/skeleton.wiki
		endif
	augroup end
endif

" }}}

" Rainbow Paranthesis {{{
let g:rainbow#max_level = 16
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

" Always Start
autocmd VimEnter * call rainbow_parentheses#activate()
" Fix for Javascript.vim conflict (right now it still doesn't look very good)
"autocmd FileType javascript syntax clear jsFuncBlock jsFuncArgs

" }}}

" End of Plugin Config }}}
