" VimWiki Helpers that me, Taylor Grote, built

" Fill it with the skeleton file
function! s:LoadWikiFile()
	" Fill 'er up
	silent execute '-1read ' . g:vimfiles_dir . '/templates/skeleton.wiki'
endfunction

" Replace text 'Title' in the current buffer with description is given
function! s:ReplaceTitle(description)
	" Run substitution on the buffer
	silent execute "%s/TITLE/" . a:description . "/g"
endfunction

function! s:ReplaceStartDate()
	" Run substitution on the buffer
	let dateTime = strftime('%c')
	" Format is MM/DD/YYYY and those '/' confuse the substitution process so we need to replace with with escaped characters
	let subCommand = '%s/START_DATE/*' . substitute(dateTime, '/', '\\/', 'g') . '*/g'
	silent execute subCommand
endfunction

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
	let skeletonFile = g:vimfiles_dir . '/templates/skeleton.wiki'
	let ticketNum = a:1
	let description = join(a:000[1:-1], ' ') "Description is the rest of the arguments joined together
	let fullTicketName = printf("Ticket-%s", ticketNum)
	let ticketFolderName = printf("Tickets/%s", fullTicketName)
	let ticketFileName = printf("./%s.wiki", ticketFolderName)

	" Find line that looks like this: '== Tickets =='
	" And then insert a new line under that as a list item
	let ticketsLineNum = search("== Tickets ==")

	execute printf("normal %dGo- [[Tickets/Ticket-%s|%s]]", ticketsLineNum, ticketNum, description)

	" Create Folder with same name as Ticket (not sure if this is a good idea)
	call mkdir(ticketFolderName)

	" Create/open new file if it doesn't exist
	" Note: This will fuckup if we have an autocmd setup for this
	silent execute "e " . ticketFileName

	" Autopopulate file with command arguments
	call s:ReplaceTitle(description)
	call s:ReplaceStartDate()
endfunction
