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

	" Find line that looks like this: '== Tickets =='
	" And then insert a new line under that as a list item
	let ticketsLineNum = search("== Tickets ==")

	execute printf("normal %dGo- [[Tickets/Ticket-%s|%s]]", ticketsLineNum, ticketNum, description)
endfunction

" TODO Add exists check
command! -nargs=+ MakeTicketLink call s:MakeTicketWithDesc(<f-args>)
