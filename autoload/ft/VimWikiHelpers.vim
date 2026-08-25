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

" Create the folder that a ticket's file lives in (e.g. "Tickets/SD-5619")
function! s:MakeTicketFolder(ticketId) abort
	let l:ticketFolderName = printf("Tickets/%s", a:ticketId)
	call mkdir(l:ticketFolderName, "p")
	return l:ticketFolderName
endfunction

" Insert a new link under the current wiki page's '## Tickets' heading and save it
function! s:InsertTicketLink(ticketId, description, ticketFileName) abort
	" Find line that looks like this: '== Tickets =='
	" And then insert a new line under that as a list item
	let l:ticketsLineNum = search("## Tickets")

	" The O will automatically prepend a '- ' if this body is a bulleted list
	execute printf("normal %dG}O[%s: %s](%s)", l:ticketsLineNum, a:ticketId, a:description, a:ticketFileName)
	write
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
	let skeletonFile = g:vimfiles_dir . '/templates/skeleton.md'
	let ticketId = a:1

	" Description is the rest of the arguments joined together
	let descriptionTokens = map(copy(a:000[1:-1]), { key, val -> substitute(v:val, "[#/-]", "", "g") })
	call filter(descriptionTokens, 'v:val != ""')   " Remove empty tokens
	let description = join(descriptionTokens, ' ')
	let ticketFolderName = s:MakeTicketFolder(ticketId)
	let ticketFileName = printf("%s/%s.md", ticketFolderName, ticketId)
	let ticketLinkPath = '/' . ticketFileName

	call s:InsertTicketLink(ticketId, description, ticketLinkPath)

	" Create/open new file if it doesn't exist
	silent execute "e ./" . ticketFileName

	" Autopopulate file with command arguments
	call s:ReplaceTitle(ticketId, description)
	call s:ReplaceStartDate()
	write
endfunction

" --- Jira URL parsing -------------------------------------------------------
" Returns [host, issueKey], or ['', ''] if the url doesn't look like a Jira
" issue link (e.g. https://midwestlabs.atlassian.net/browse/SD-5619)
function! s:ParseJiraUrl(url) abort
	let l:m = matchlist(a:url, '^https\?://\([^/]\+\)/browse/\(\w\+-\d\+\)')
	if empty(l:m)
		return ['', '']
	endif
	return [l:m[1], l:m[2]]
endfunction

" --- Jira REST API v3 fetch -------------------------------------------------
" Uses `curl -K -` (config read from stdin) so the URL/auth never pass through
" cmd.exe's own argument parsing or show up in a process listing.
"
" Requires $JIRA_EMAIL and $JIRA_API_TOKEN to be set in the environment:
"   1. Log into https://id.atlassian.com/manage-profile/security/api-tokens
"      (with the same Atlassian account you use for midwestlabs.atlassian.net)
"      and click "Create API token". Copy it immediately - it's only shown once.
"   2. Set two Windows environment variables:
"        JIRA_EMAIL       - the email address on that Atlassian account
"        JIRA_API_TOKEN   - the token you just copied
"      Either via System Properties > Environment Variables, or from a
"      terminal: `setx JIRA_EMAIL "you@example.com"` and
"      `setx JIRA_API_TOKEN "<token>"`.
"   3. New/changed environment variables are only picked up by processes
"      started AFTER they're set - existing terminals/GVim windows won't see
"      them. Log off and back on (or reboot) so Explorer-launched apps like
"      GVim inherit the new values; simply opening a new window is often not
"      enough, since it may still inherit Explorer's stale environment.
function! s:FetchJiraIssue(host, key) abort
	if empty($JIRA_EMAIL) || empty($JIRA_API_TOKEN)
		echo 'NewJiraTicket: set $JIRA_EMAIL and $JIRA_API_TOKEN environment variables first.'
		return {}
	endif

	let l:apiUrl = printf('https://%s/rest/api/3/issue/%s?fields=summary,description', a:host, a:key)
	let l:curlConfig = 'url = "' . l:apiUrl . '"' . "\n"
				\ . 'header = "Accept: application/json"' . "\n"
				\ . 'user = "' . $JIRA_EMAIL . ':' . $JIRA_API_TOKEN . '"' . "\n"

	let l:response = system('curl -s -K -', l:curlConfig)
	if v:shell_error != 0
		echo 'NewJiraTicket: curl failed to run (is curl installed and on PATH?).'
		return {}
	endif

	try
		let l:decoded = json_decode(l:response)
	catch
		echo 'NewJiraTicket: could not parse the Jira response as JSON.'
		return {}
	endtry

	if type(l:decoded) == v:t_dict && has_key(l:decoded, 'errorMessages')
		echo 'NewJiraTicket: Jira error - ' . join(l:decoded.errorMessages, '; ')
		return {}
	endif
	return l:decoded
endfunction

" --- ADF (Atlassian Document Format) -> plain lines -------------------------
" Not a full ADF renderer - handles the common cases (paragraphs, headings,
" hard breaks, links, bullet/ordered lists) and best-effort flattens anything
" else (tables, panels, media, ...) rather than crashing on them.
function! s:AdfInlineToText(node) abort
	if type(a:node) != v:t_dict
		return ''
	endif
	let l:type = get(a:node, 'type', '')
	if l:type ==# 'text'
		let l:text = get(a:node, 'text', '')
		for l:mark in get(a:node, 'marks', [])
			if type(l:mark) == v:t_dict && get(l:mark, 'type', '') ==# 'link'
				let l:href = get(get(l:mark, 'attrs', {}), 'href', '')
				if !empty(l:href)
					let l:text = printf('[%s](%s)', l:text, l:href)
				endif
			endif
		endfor
		return l:text
	elseif l:type ==# 'hardBreak'
		return "\n"
	elseif has_key(a:node, 'content') && type(a:node.content) == v:t_list
		return join(map(copy(a:node.content), 's:AdfInlineToText(v:val)'), '')
	else
		return ''
	endif
endfunction

function! s:AdfBlockToLines(node) abort
	if type(a:node) != v:t_dict
		return []
	endif
	let l:type = get(a:node, 'type', '')
	if l:type ==# 'paragraph' || l:type ==# 'heading'
		let l:text = join(map(copy(get(a:node, 'content', [])), 's:AdfInlineToText(v:val)'), '')
		return split(l:text, "\n", 1)
	elseif l:type ==# 'bulletList' || l:type ==# 'orderedList'
		let l:lines = []
		let l:num = 1
		for l:item in get(a:node, 'content', [])
			let l:itemLines = []
			for l:child in get(l:item, 'content', [])
				call extend(l:itemLines, s:AdfBlockToLines(l:child))
			endfor
			if !empty(l:itemLines)
				let l:prefix = l:type ==# 'bulletList' ? '- ' : (l:num . '. ')
				call add(l:lines, l:prefix . l:itemLines[0])
				call extend(l:lines, map(l:itemLines[1:], '"  " . v:val'))
			endif
			let l:num += 1
		endfor
		return l:lines
	elseif has_key(a:node, 'content') && type(a:node.content) == v:t_list
		let l:lines = []
		for l:child in a:node.content
			call extend(l:lines, s:AdfBlockToLines(l:child))
		endfor
		return l:lines
	else
		return []
	endif
endfunction

function! s:AdfDocToLines(doc) abort
	if type(a:doc) != v:t_dict || get(a:doc, 'type', '') !=# 'doc'
		return []
	endif
	let l:blocks = []
	for l:node in get(a:doc, 'content', [])
		let l:blockLines = s:AdfBlockToLines(l:node)
		if !empty(l:blockLines)
			call add(l:blocks, l:blockLines)
		endif
	endfor
	let l:result = []
	for l:i in range(len(l:blocks))
		if l:i > 0
			call add(l:result, '')
		endif
		call extend(l:result, l:blocks[l:i])
	endfor
	return l:result
endfunction

function! s:AdfDocToLinesSafe(doc) abort
	try
		return s:AdfDocToLines(a:doc)
	catch
		echo 'NewJiraTicket: could not fully parse the Jira description; leaving it out.'
		return []
	endtry
endfunction

" --- File content ------------------------------------------------------------
" Reuses only the static "## Research / ## Development / ## Go Live" tail of
" templates/skeleton.md (everything after the START_DATE placeholder), so
" editing that boilerplate keeps both commands in sync. The header/description
" part is built directly since its shape differs from the plain-text skeleton,
" and Jira-sourced text can contain regex-special characters that would break
" the :substitute-based approach s:ReplaceTitle/s:ReplaceStartDate use.
function! s:BuildJiraTicketLines(key, summary, url, descriptionLines) abort
	let l:template = readfile(expand(g:vimfiles_dir . '/templates/skeleton.md'))
	let l:dateIdx = index(l:template, '**START_DATE**')
	let l:boilerplateTail = l:dateIdx == -1 ? [] : l:template[l:dateIdx + 1 :]

	let l:lines = [printf('# %s: %s', a:key, a:summary), '', '## Description',
				\ printf('- Creation Time: **%s**', strftime('%#m/%#d/%Y %#I:%M:%S %p')),
				\ printf('- %s', a:url)]
	if !empty(a:descriptionLines)
		call add(l:lines, '')
		call extend(l:lines, a:descriptionLines)
	endif
	call extend(l:lines, l:boilerplateTail)
	return l:lines
endfunction

" Create a new ticket file/folder populated from a Jira issue, and link it
" from the current wiki page's '## Tickets' heading, e.g.:
"   :NewJiraTicket https://midwestlabs.atlassian.net/browse/SD-5619
function! ft#VimWikiHelpers#MakeTicketFromJira(url) abort
	let [l:host, l:key] = s:ParseJiraUrl(a:url)
	if empty(l:key)
		echo 'NewJiraTicket: could not find a Jira issue key in url: ' . a:url
		return
	endif

	let l:issue = s:FetchJiraIssue(l:host, l:key)
	if empty(l:issue)
		return
	endif

	let l:fields = get(l:issue, 'fields', {})
	let l:summary = get(l:fields, 'summary', l:key)
	let l:descriptionLines = s:AdfDocToLinesSafe(get(l:fields, 'description', {}))

	let l:ticketFolderName = s:MakeTicketFolder(l:key)
	let l:ticketFileName = printf('%s/%s.md', l:ticketFolderName, l:key)
	let l:ticketLinkPath = '/' . l:ticketFileName

	call s:InsertTicketLink(l:key, l:summary, l:ticketLinkPath)

	call writefile(s:BuildJiraTicketLines(l:key, l:summary, a:url, l:descriptionLines), l:ticketFileName)
	silent execute 'e ./' . l:ticketFileName
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

" Regenerate the vimwiki diary index (diary.md) so it links the current
" buffer's diary entry, then save and close the index without disturbing
" the calling window. Must be called from within a diary entry buffer
" (e.g. the BufNewFile */diary/*.md autocmd in vimrc when a new diary page
" is created), since the entry has to exist on disk for
" VimwikiDiaryGenerateLinks' file scan to pick it up.
function! ft#VimWikiHelpers#UpdateDiaryIndex()
	silent update
	split
	silent VimwikiDiaryIndex
	VimwikiDiaryGenerateLinks
	silent write
	let l:diary_bufnr = bufnr('%')
	close
	execute 'bwipeout ' . l:diary_bufnr
endfunction

" Convert a range of '- ' unordered list lines (e.g. from a visual selection)
" into a numbered list, preserving indentation. Tracks a stack of
" [indent, counter] pairs so that each new nested block (deeper indentation)
" restarts its numbering at 1, rather than one running counter per indent
" depth that never resets.
function! ft#VimWikiHelpers#ConvertToNumberedList(startLine, endLine) abort
	let l:stack = []
	for l:lnum in range(a:startLine, a:endLine)
		let l:m = matchlist(getline(l:lnum), '^\(\s*\)-\s\+\(.*\)$')
		if empty(l:m)
			continue
		endif
		let [l:indent, l:rest] = l:m[1:2]

		while !empty(l:stack) && len(l:stack[-1][0]) > len(l:indent)
			call remove(l:stack, -1)
		endwhile

		if !empty(l:stack) && l:stack[-1][0] ==# l:indent
			let l:stack[-1][1] += 1
		else
			call add(l:stack, [l:indent, 1])
		endif

		call setline(l:lnum, l:indent . l:stack[-1][1] . '. ' . l:rest)
	endfor
endfunction
