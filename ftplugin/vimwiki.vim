" Vimwiki file types

set spell

command! -buffer -nargs=+ NewTicket call ft#VimWikiHelpers#MakeTicketWithDesc(<f-args>)
command! -buffer -nargs=+ NewSection normal! Go<CR>== <args> ==<CR><ESC>

" Mapping to insert Date Time Stamp surrounded by ** as a newline, and then end on said newline
nnoremap <silent><buffer> <Leader>ts i*<C-R>=strftime('%c')<CR>*<CR><ESC>

