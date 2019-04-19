" Vimwiki file types

" Function designed for the main wiki page that will add a new wiki page link
" arguments:
" 1 = Ticket Number
" 2+ = Description
function! s:MakeTicketWithDesc(...)
	" Check num args
	if a:0 < 2
		echo "MakeTicketWithDesc requires 2 arguments"
		return
	endif

	" Get Arguments
	let ticketNum = a:1
	let description = join(a:000[1:-1], ' ') "Description is the rest of the arguments joined together
	let fullTicketName = printf("Ticket-%s", ticketNum)
	let ticketFolderName = printf("Tickets/%s", fullTicketName)

	" Find line that looks like this: '== Tickets =='
	" And then insert a new line under that as a list item
	let ticketsLineNum = search("== Tickets ==")

	execute printf("normal %dGo- [[Tickets/Ticket-%s|%s]]", ticketsLineNum, ticketNum, description)

	" Create Folder with same name as Ticket (not sure if this is a good idea)
	call mkdir(ticketFolderName)

	" TODO Create new file if it doesn't exist
	" TODO Open ticket file
	" TODO Autopopulate file with command arguments
endfunction

" TODO Add exists check
command! -nargs=+ NewTicket call s:MakeTicketWithDesc(<f-args>)
command! -nargs=+ NewSection normal! Go<CR>== <args> ==<CR><ESC>

" Mapping to insert Date Time Stamp surrounded by ** as a newline, and then end on said newline
nnoremap <silent> <Leader>ts i*<C-R>=strftime('%c')<CR>*<CR><ESC>

