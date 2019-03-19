" Javascript specific config

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
function! s:GetIdeaFoldDesc(lnum)
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
