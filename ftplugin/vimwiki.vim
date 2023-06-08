" Vimwiki file types

set spell

command! -buffer -nargs=+ NewTicket call ft#VimWikiHelpers#MakeTicketWithDesc(<f-args>)

" Mapping to insert Date Time Stamp surrounded by ** as a newline, and then end on said newline
nnoremap <silent><buffer> <Leader>ts a**<C-R>=strftime('%c')<CR>**<ESC>
nnoremap <silent><buffer> <Leader>date a<C-R>=strftime('%F')<CR><ESC>

set foldlevelstart=2

