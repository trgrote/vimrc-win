" Vimwiki file types

set spell

command! -buffer -nargs=+ NewTicket call ft#VimWikiHelpers#MakeTicketWithDesc(<f-args>)

" Mapping to insert Date Time Stamp surrounded by ** as a newline, and then end on said newline
nnoremap <silent><buffer> <Leader>ts i**<C-R>=strftime('%c')<CR>**<ESC>
nnoremap <silent><buffer> <Leader>date a<C-R>=strftime('%F')<CR><ESC>

" Close Calendar buffer
command! CalendarClose bwipeout! __Calendar

set foldlevelstart=2

" Replace weird quotes that jira sometimes puts in that will cause the gollum
" wiki to crash
augroup replacequotesgroup
	autocmd!

	" Pre Save, substitute all weird quotes with a normal double quote
	" Do this for all occurrences in each line
	" do not error if no weird quotes were found
	autocmd BufWritePre *.md %s/[“”]/"/ge
augroup end
