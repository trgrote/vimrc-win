" Do a lvimgrep recursive search and open the results window
function! search#search(search_pattern) abort
	" Search for 1.pattern
	if empty(a:search_pattern)
		echo 'No search pattern given.'
		return
	endif

	let pattern = a:search_pattern

	" If the pattern does not start with a '/', then we'll assume that a
	" literal search is intended and enclose and escape it:
	if match(pattern, '^/') == -1
		let pattern = '/' . escape(pattern, '\') . '/'
	endif

	let path = fnameescape(getcwd())

	" Include j to not automatically do to the first match.
	" Without this, the first match file would be opened with no syntax
	" highlighting (since noautocmd stops autocmds from running)
	let cmd  = 'noautocmd lvimgrep ' . pattern . 'j ' . path . '**'

	" Catch E480 error from lvimgrep if there's no match and present
	" a friendlier error message.
	try
		execute cmd
		lopen
	catch
		echo 'Search: No match found.'
	endtry
endfunction
