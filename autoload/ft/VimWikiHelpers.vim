" VimWiki Helpers that me, Taylor Grote, built

" Local Functions {{{
" Fill it with the skeleton file
" Requires the g:vimfiles_dir to be a string indicating the vimfiles directory
" for the current machine (this should be in my vimrc file)
function! s:LoadWikiFile()
	" Fill 'er up
	silent execute '-1read ' . g:vimfiles_dir . '/templates/skeleton.md'
endfunction

" Replace text 'Title' in the current buffer with description is given
function! s:ReplaceTitle(ticketId, description)
	" Run substitution on the buffer
	silent execute "%s/TITLE/" . a:ticketId . ": " . a:description . "/g"
endfunction

" Replace start date with actual current start date
function! s:ReplaceStartDate()
	" Run substitution on the buffer
	let l:dateTime = strftime('%c')
	" Format is MM/DD/YYYY and those '/' confuse the substitution process so we need to replace with with escaped characters
	let l:subCommand = '%s/START_DATE/' . substitute(l:dateTime, '/', '\\/', 'g') . '/g'
	silent execute l:subCommand
endfunction
" }}}

" Function designed for the main wiki page that will add a new wiki page link
" arguments:
" 1 = Ticket Number
" 2+ = Description
function! ft#VimWikiHelpers#MakeTicketWithDesc(...)
	" Check num args
	if a:0 < 2
		echo "MakeTicketWithDesc requires 2 arguments"
		return
	endif

	" Get Arguments
	let skeletonFile = g:vimfiles_dir . '/templates/skeleton.md'
	let ticketId = a:1

	" Description is the rest of the arguments joined together
	let descriptionTokens = map(copy(a:000[1:-1]), { key, val -> substitute(v:val, "[#/-]", "", "g") })
	call filter(descriptionTokens, 'v:val != ""')   " Remove empty tokens
	let description = join(descriptionTokens, ' ')
	let ticketFolderName = printf("Tickets/%s", ticketId)
	let ticketFileName = printf("%s/%s.md", ticketFolderName, ticketId)

	" Create Folder with same name as Ticket
	call mkdir(ticketFolderName, "p")

	" Find line that looks like this: '== Tickets =='
	" And then insert a new line under that as a list item
	let ticketsLineNum = search("## Tickets")

	" The O will automatically prepend a '- ' if this body is a bulleted list
	execute printf("normal %dG}O[%s: %s](%s)", ticketsLineNum, ticketId, description, ticketFileName)
	write

	" Create/open new file if it doesn't exist
	silent execute "e ./" . ticketFileName

	" Autopopulate file with command arguments
	call s:ReplaceTitle(ticketId, description)
	call s:ReplaceStartDate()
	write
endfunction
