" Javascript specific config
set nospell

" Intellij Editor Folding {{{
setlocal foldmethod=expr
setlocal foldexpr=GetIdeaFold(v:lnum)
setlocal foldtext=GetIdeaFoldText()

" Return fold
function! GetIdeaFold(lnum)
	" If the line is the start of editor fold
	if getline(a:lnum) =~? '\v^.*\/\/\<editor-fold'
		return '>1'
	elseif getline(a:lnum) =~? '\v^.*\/\/\</editor-fold'
		return '<1'
	endif
	return '-1'
endfunction

" Helper Function to get description field from editor fold
function! GetIdeaFoldDesc(lnum)
	let line = getline(a:lnum)
	return matchstr(line, 'desc="\zs[^"]\+\ze"')
endfunction

" Fold Text
function! GetIdeaFoldText()
	let startLine = getline(v:foldstart)
	let numLines = v:foldstop - v:foldstart + 1
	let desc = GetIdeaFoldDesc(v:foldstart)
	let foldStart = '+' . repeat('-', v:foldlevel * 2)

	return foldStart . desc
endfunction
" }}}

" Generate Editor Folding {{{
function! s:MakeIntellijFolding(desc) abort
	" Append new lines to before and after visual selection
	" include the description argument
	call append(line("'<")-1, '//<editor-fold desc="' . a:desc . '">')
	call append(line("'>"), '//</editor-fold>')

	" Highlights the tagged area and formats it (may not want to do that, only
	" want to format new lines)
	normal! vat=
endfunction

" https://vi.stackexchange.com/questions/4753/is-it-possible-to-create-mappings-with-parameters
vnoremap <leader>e :<c-u>call <sid>MakeIntellijFolding(input("Description: "))<CR>

" }}}

