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

function! s:findIndex(values, Expr)
	let currentIndex = 0

	while currentIndex < len(a:values)
		let value = a:values[currentIndex]
		if a:Expr(value) > 0
			return currentIndex
		endif
		let currentIndex = currentIndex + 1
	endwhile

	return -1
endfunction

function! s:GetPreviousTODOS(currentDayFileName)
	let diaryFiles = readdir(g:calendar_diary, {n -> n =~ '^\d\{4\}-\d\{2\}-\d\{2\}.md$'})
	let defaultReturn = ["- [ ] "]

	" Insert the current day's file (which probably doesn't exist yet) in order to split the list between previous days and future days
	let appendedDiaryFiles = add(copy(diaryFiles), a:currentDayFileName)
	call sort(appendedDiaryFiles)
	call uniq(appendedDiaryFiles)

	let currentDayIndex = index(appendedDiaryFiles, a:currentDayFileName)   " returns -1 if not found

	let previousDiaries = slice(appendedDiaryFiles, 0, currentDayIndex)

	" If no Previous Diaries found
	if len(previousDiaries) == 0
		return defaultReturn
	endif

	let previousDiary = previousDiaries[-1]

	" Read in previous day diary
	let previousDiaryContent = readfile(g:calendar_diary . "/" . previousDiary)

	" Isolate TODO section
	let todoStart = index(previousDiaryContent, "## TODO")

	" If no TODO Found in previous diary or it's the last line in the file
	if todoStart == -1 || todoStart + 1 >= len(previousDiaryContent)
		return defaultReturn
	endif

	let todoEnd = s:findIndex(previousDiaryContent[todoStart + 1:], {l -> l =~ '^## '})

	" If we couldn't find the end of the todo section, that means it's just the end of the file
	let todoEnd = todoEnd == -1 ? len(previousDiaryContent) : (todoStart + 1 + todoEnd)
	let todoSection = slice(previousDiaryContent, todoStart + 1, todoEnd)

	" Only grab incomplete things
	call filter(todoSection, {idx, val -> val =~ '- \[[^X]\]'})

	" Return
	if len(todoSection) == 0
		return defaultReturn
	endif

	" Change every non empty checkbox with an empty checkbox
	call map(todoSection, {idx, val -> substitute(val, '- \[[^X]\]', '- [ ]', '')})

	return todoSection + defaultReturn
endfunction

function! ft#VimWikiHelpers#AppendPreviousTODO(fileName)
	let prevTodoLines = s:GetPreviousTODOS(a:fileName)
	call append(line('$'), prevTodoLines)
endfunction
