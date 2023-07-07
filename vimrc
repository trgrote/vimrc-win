" Vim Home Directory is different depending on which OS we're in {{{
let g:vimfiles_dir = '~/.vim'
if has('win32')
	let g:vimfiles_dir = '~/vimfiles'
endif
" }}}

" Plug Section {{{
" Vim Files folder location (based off OS)
let autoload_dir = g:vimfiles_dir . '/autoload'

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
call plug#begin(g:vimfiles_dir . '/plugged')

Plug 'FooSoft/vim-argwrap'
Plug 'OrangeT/vim-csharp'
Plug 'PProvost/vim-ps1'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'flazz/vim-colorschemes'
Plug 'godlygeek/tabular'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'mhinz/vim-startify'
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'qpkorr/vim-bufkill'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'sickill/vim-monokai'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'triglav/vim-visual-increment'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny' }
if has('win32')
	Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
	Plug 'trgrote/calendar-vim'
endif

" Initialize plugin system
call plug#end()

" Automatically install if any plugins are missing
autocmd VimEnter *
			\  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
			\|   PlugInstall --sync | q
			\| endif

" End of Plug }}}

" Window Size
if has('win32')
	set lines=80 columns=150
endif

"Personal Settings.
"More to be added soon.
set nocompatible
"Set the status line options. Make it show more information.
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}
"Set Color Scheme and Font Options
colorscheme monokai
set guifont=Consolas:h13
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
set list
if has('win32')
	set listchars=tab:>-,trail:•
else
	set listchars=tab:>-,trail:*
endif

" Disable weird background highlighting that happens for list characters
hi SpecialKey guibg=NONE ctermbg=NONE

" Wrap it up boy
set wrap
" Disable automatic newline insertion after X amount of chars
set textwidth=0
set linebreak
set wrapmargin=0
set formatoptions=cqt
set lazyredraw   " Don't redraw after during a macro run

" Set Mapleader
let mapleader="\<Space>"

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

" JSON Prettifier (Only works if python is installed in path)
vmap <silent> <leader>json :!python -m json.tool<CR>

" Sql Prettifier requires the below python package
" pip install sqlparse
vmap <silent> <leader>sql :!sqlformat --reindent --keywords upper --identifiers lower -<CR>

" Delete current buffer only works if you have tpope/vim-unimpaired
nnoremap <silent> <Leader>bd :BD<CR>

" Bull kill all
nnoremap <silent> <Leader>bka :.+,$bwipeout<CR>

" Swap and Backup files
set nobackup
set noswapfile

" Note Header shortuct
nnoremap <Leader>3 080i#<ESC>a<CR>#<Space>

" I like folding Markers
set foldmethod=marker

" Set the spell window to something smaller
set spellsuggest+=10

" Change splits to appear to the right (vertical)
set splitright

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

" Add show current folder in explorer command
if has('win32')
	" Open file explorer in the current file's directory
	command! ShowInExplorer execute 'silent !start /b explorer ' . expand('%:p:h')
endif

" Open a new file in the same directory as the current file
command! -nargs=1 NewFile call s:NewFile(<q-args>)
function! s:NewFile(fp)
	execute "e " . expand("%:h") . "/" . a:fp
endfunction

" Plugin Configurations {{{

" CtrlP Options
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$',
			\ 'file': '\v\.(exe|so|dll|meta|csproj|sln|manifest|suo|pdb|user|jmconfig)$'
			\ }
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

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
vmap <silent> <leader>t# :Tabularize /#/l4l1<CR>
vmap <silent> <leader>t=> :Tabularize /=><CR>

" ArgWrap
nnoremap <silent> <leader>a :ArgWrap<CR>

" Insert DateTime stamp (useful for notes)
nnoremap <leader>dt "=strftime('%c')<CR>gp

" vimwiki/vimwiki {{{
let g:vimwiki_list = [
			\{
			\'path'      : '~/vimwiki/mwl/',
			\'index'     : 'Home',
			\'syntax'    : 'markdown',
			\'ext'       : '.md'
			\}
			\]

let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_folding = 'expr'

" Header Colors (stolen from http://www.eclipsecolorthemes.org/?view=theme&id=6093)
hi VimwikiHeader1 guifg=#F92672
hi VimwikiHeader2 guifg=#AE81FF
hi VimwikiHeader3 guifg=#A6E22E
hi VimwikiHeader4 guifg=#66D9EF
hi VimwikiHeader5 guifg=#FFE792
hi VimwikiHeader6 guifg=#F8F8F2

" VimWiki skeleton file
if has("autocmd")
	augroup wiki_templates
		au!
		if has('win32')
			autocmd BufNewFile *.md 0r ~/vimfiles/templates/skeleton.md
		else
			autocmd BufNewFile *.md 0r ~/.vim/templates/skeleton.md
		endif
	augroup end
endif

let g:calendar_diary=$HOME.'/vimwiki/mwl/diary'

function CloseCalendarBuffer(day, month, year, week, dir)
	bwipeout! __Calendar
endfunction

let g:calendar_action_end = "CloseCalendarBuffer"

function! s:findIndex(values, Expr)
	let currentIndex = 0

	while currentIndex < len(a:values)
		let value = a:values[currentIndex]
		if a:Expr(value) > 0
			return currentIndex
		endif
		let currentIndex = currentIndex + 1
	endwhile

	return -1
endfunction

function! s:GetPreviousTODOS(currentDayFileName)
	let diaryFiles = readdir(g:calendar_diary, {n -> n =~ '^\d\{4\}-\d\{2\}-\d\{2\}.md$'})
	let defaultReturn = ["- [ ] "]

	" Insert the current day's file (which probably doesn't exist yet) in order to split the list between previous days and future days
	let appendedDiaryFiles = add(copy(diaryFiles), a:currentDayFileName)
	call sort(appendedDiaryFiles)
	call uniq(appendedDiaryFiles)

	let currentDayIndex = index(appendedDiaryFiles, a:currentDayFileName)   " returns -1 if not found

	let previousDiaries = slice(appendedDiaryFiles, 0, currentDayIndex)

	" If no Previous Diaries found
	if len(previousDiaries) == 0
		return defaultReturn
	endif

	let previousDiary = previousDiaries[-1]

	" Read in previous day diary
	let previousDiaryContent = readfile(g:calendar_diary . "/" . previousDiary)

	" Isolate TODO section
	let todoStart = index(previousDiaryContent, "## TODO")

	" If no TODO Found in previous diary or it's the last line in the file
	if todoStart == -1 || todoStart + 1 >= len(previousDiaryContent)
		return defaultReturn
	endif

	let todoEnd = s:findIndex(previousDiaryContent[todoStart + 1:], {l -> l =~ '^## '})

	" If we couldn't find the end of the todo section, that means it's just the end of the file
	let todoEnd = todoEnd == -1 ? len(previousDiaryContent) : (todoStart + 1 + todoEnd)
	let todoSection = slice(previousDiaryContent, todoStart + 1, todoEnd)

	" Only grab incomplete things
	call filter(todoSection, {idx, val -> val =~ '- \[[^X]\]'})

	" Return
	if len(todoSection) == 0
		return defaultReturn
	endif

	" Change every non empty checkbox with an empty checkbox
	call map(todoSection, {idx, val -> substitute(val, '- \[[^X]\]', '- [ ]', '')})

	return todoSection + defaultReturn
endfunction

function! s:AppendPreviousTODO(fileName)
	let prevTodoLines = s:GetPreviousTODOS(a:fileName)
	call append(line('$'), prevTodoLines)
endfunction

" Vimwiki Diary autoindexing when visiting index page
augroup vimwikigroup
	autocmd!
	" automatically update links on read diary
	autocmd BufRead,BufNewFile diary.md VimwikiDiaryGenerateLinks

	" Override default Wiki page with the Diary format and replace the DATE
	" placeholder with the file name w/o extension
	autocmd BufNewFile */diary/*.md %d
				\ | 0r ~/vimfiles/templates/skeleton.diary.md
				\ | $d
				\ | %s/DATE/\=expand('%:t:r')/g
				\ | call s:AppendPreviousTODO(expand('%:t'))
				\ | $
				\ | call append(line('$'), "")
				\ | norm $
augroup end

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
