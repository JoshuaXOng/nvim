vim.cmd([[
    " Just for NVim.
    tnoremap <C-W>"" <C-\><C-N>""pa

    let g:netrw_baner = 0
    let g:netrw_list_hide = '.*\.swp$'

    set colorcolumn=80
    set ts=4 sw=4 expandtab smarttab autoindent
    set rnu nu foldmethod=indent hls
    set autochdir path=** wildmenu wildignore=**/.git/**,**/node_modules/**,**/target/**,**/build/**
    let g:netrw_keepdir = 0
    let g:netrw_bufsettings = "noma nomod nu rnu nobl nowrap ro"
    set shortmess-=S hidden nobackup nowritebackup
    set statusline=%{expand('%:p')}%{'\ \ '.winnr()}
    let mapleader = " "
    nmap <space> <nop>
    nmap <leader>l gt
    nmap <leader>h gT
    nmap <leader>e :execute 'r! sh -c "' . getline('.') . '"'<cr>
    nmap j gj
    nmap k gk
    command! Term term ++curwin
    tmap <c-\> <c-\><c-n>
    nmap <leader>w <c-w>
    command! Tn tabnew 
    command! -nargs=1 Tm tabmove <args>
    cmap <c-l> <c-r>0

    function! GotoPreviousWord()
        let l:cursor_position = getpos(".")
        let l:reversed_line = join(reverse(split(getline("."), ".\\zs")), "")
        let l:reversed_index = strlen(l:reversed_line) - l:cursor_position[2] + 1

        let l:target_offset = match(reversed_line[l:reversed_index:], "[_A-Z]")
        if l:target_offset != -1
            let l:cursor_position[2] = l:cursor_position[2] - l:target_offset - 1
            call setpos(".", l:cursor_position)
        endif
    endfunction
    noremap B :call GotoPreviousWord()<cr>

    function! GotoNextWord()
        let l:cursor_position = getpos(".")
        let l:target_offset = match(getline(".")[l:cursor_position[2]:], "[_A-Z]")
        let l:cursor_position[2] = l:cursor_position[2] + l:target_offset + 1
        call setpos(".", l:cursor_position)
    endfunction
    noremap W :call GotoNextWord()<cr>

    function! GotoPreviousEmptyLine(cursor_position) range
        call cursor(a:cursor_position[1], a:cursor_position[2])    
        call setpos("'>", [0] + searchpos("^\\s*$", "nbW") + [0])
        norm gv
    endfunction
    function! GotoPreviousEmptyLine_() range
        let l:cursor_position = string(getpos("."))
        return ":\<c-u>call GotoPreviousEmptyLine(" . l:cursor_position . ")\<cr>"
    endfunction
    vnoremap <expr> { GotoPreviousEmptyLine_()
    nnoremap { :call search("^\\s*$", "bW")<cr>

    function! GotoNextEmptyLine(cursor_position) range
        call cursor(a:cursor_position[1], a:cursor_position[2])    
        call setpos("'>", [0] + searchpos("^\\s*$", "nW") + [0])
        norm gv
    endfunction
    function! GotoNextEmptyLine_() range
        let l:cursor_position = string(getpos("."))
        return ":\<c-u>call GotoNextEmptyLine(" . l:cursor_position . ")\<cr>"
    endfunction
    vnoremap <expr> } GotoNextEmptyLine_()
    nnoremap } :call search("^\\s*$", "W")<cr>

    function! GotoIndent(indent_predicate, end_symbol, cursor_position)
        if a:cursor_position isnot v:null
            call cursor(a:cursor_position[1], a:cursor_position[2])    
        endif
        let l:current_column = match(getline("."), "\\S")

        if a:end_symbol == "^"
            let l:search_section = range(line(".") - 1, line(a:end_symbol) - 1, -1)
        elseif a:end_symbol == "$"
            let l:search_section = range(line(".") + 1, line(a:end_symbol) + 1)
        endif

        for l:line_index in l:search_section
            let l:first_nonspace = match(getline(line_index), "\\S")
            if l:first_nonspace == -1
                continue
            endif

            if (a:indent_predicate == "same" && l:first_nonspace == l:current_column) ||
            \ (a:indent_predicate == "left" && l:first_nonspace < l:current_column) ||
            \ (a:indent_predicate == "right" && l:first_nonspace > l:current_column)
                let l:cursor_position = getpos(".")
                let l:cursor_position[1] = l:line_index
                if a:cursor_position isnot v:null
                    call setpos("'>", l:cursor_position)
                else
                    call setpos(".", l:cursor_position)
                endif
                break
            endif
        endfor
        if a:cursor_position isnot v:null
            norm gv
        endif 
    endfunction
    function! GotoIndent_(indent_predicate, end_symbol) range
        let l:cursor_position = string(getpos("."))
        return ":\<c-u>call GotoIndent(" . a:indent_predicate . ", " . a:end_symbol . ", " . l:cursor_position . ")\<cr>"
    endfunction

    vnoremap <expr> A GotoIndent_("\"left\"", "\"^\"")
    nnoremap <expr> A ":\<c-u>call GotoIndent(" . "\"left\", " . "\"^\", " . "v:null" . ")\<cr>"
    vnoremap <expr> S GotoIndent_("\"same\"", "\"^\"")
    nnoremap <expr> S ":\<c-u>call GotoIndent(" . "\"same\", " . "\"^\", " . "v:null" . ")\<cr>"
    vnoremap <expr> Z GotoIndent_("\"left\"", "\"$\"")
    nnoremap <expr> Z ":\<c-u>call GotoIndent(" . "\"left\", " . "\"$\", " . "v:null" . ")\<cr>"
    vnoremap <expr> X GotoIndent_("\"same\"", "\"$\"")
    nnoremap <expr> X ":\<c-u>call GotoIndent(" . "\"same\", " . "\"$\", " . "v:null" . ")\<cr>"

    function! GetBufferDirectory()
        let @0 = expand('%:p')
    endfunction
    command! Bd call GetBufferDirectory()

    function! HighlightWord()
        let l:cword = expand('<cword>')
        let @/ = cword
    endfunction
    nnoremap <leader>f :call HighlightWord()<cr>

    function! SyncWorkingDirectory()
        let l:parent_path = expand('%:p:h')
        if isdirectory(l:parent_path)
            execute 'cd ' . fnameescape(l:parent_path)
        endif
    endfunction
    nmap <leader>s :call SyncWorkingDirectory()<cr>

    nnoremap <leader>1 :1wincmd w<cr>
    nnoremap <leader>2 :2wincmd w<cr>
    nnoremap <leader>3 :3wincmd w<cr>
    nnoremap <leader>4 :4wincmd w<cr>
    nnoremap <leader>5 :5wincmd w<cr>
    nnoremap <leader>6 :6wincmd w<cr>
    nnoremap <leader>7 :7wincmd w<cr>
    nnoremap <leader>8 :8wincmd w<cr>
    nnoremap <leader>9 :9wincmd w<cr>

    function! Close(window_numbers)
        let l:window_numbers = reverse(sort(split(a:window_numbers)))
        for l:window_number in l:window_numbers
            exec l:window_number . " wincmd w | close"
        endfor
    endfunction
    command! -nargs=* Close call Close(<q-args>)

    function! Only(window_numbers)
        let l:window_numbers = split(a:window_numbers)

        let l:complementary_numbers = reverse(sort(filter(
            \ range(1, winnr("$")),
            \ { _, x -> index(l:window_numbers, string(x)) < 0 })))
        for l:to_close in l:complementary_numbers
            exec l:to_close . " wincmd w | close"
        endfor
    endfunction
    command! -nargs=* Only call Only(<q-args>)

    nnoremap <leader>v :wincmd v<cr>:wincmd l<cr>

    function TrimBuffers()
        for l:buffer_payload in getbufinfo()
            if l:buffer_payload["loaded"] == 1 && len(l:buffer_payload["windows"]) == 0
                exec "bd! " . l:buffer_payload["bufnr"]
            endif
        endfor
    endfunction
    command! Tb call TrimBuffers()

    function KeepTabsBuffers(...)
        let l:to_keep = []
        for l:tab_number in a:000
            for l:to_keep_ in tabpagebuflist(l:tab_number)
                call add(l:to_keep, l:to_keep_)
            endfor
        endfor

        for l:buffer_payload in getbufinfo()
            let l:buffer_number = l:buffer_payload["bufnr"]
            let l:is_not_in = index(l:to_keep, l:buffer_number) == -1
            if l:buffer_payload["loaded"] == 1 && l:is_not_in
                exec "bd! " . l:buffer_number
            endif
        endfor
    endfunction
    command! -nargs=+ Ktb call KeepTabsBuffers(<f-args>)

    function! ExchangeWindowBuffers()
        let current_window = winnr()
        let current_buffer = bufnr("%")
        let previous_window = winnr("#")
        let previous_buffer = winbufnr(previous_window)
  
        exec previous_window . " wincmd w" . " | " .
            \ "buffer " . current_buffer . " | " .
            \ current_window ." wincmd w" . " | " .
            \ "buffer " . previous_buffer

        q

        wincmd p  
    endfunction

    function! ExchangeCurrentBufferWithLocationList()
        lopen
        call ExchangeWindowBuffers()
    endfunction

    let g:SANDPIT_FILENAME = ".sandpit"
    let g:FIND_IGNORES = join(['-not -path "**/.git/**"',
        \ '-not -path "**/node_modules/**"',
        \ '-not -path "**/target/**"',
        \ '-not -path "**/build/**"',
        \ '-not -path "**/plugin/**"'], ' ')

    function! GetStartPosition(ignore_count, vertical_range)
        let l:ignore_count_ = a:ignore_count
        let l:start_point = './'
        for _ in range(1, a:vertical_range)
            let l:current_ls = systemlist('ls -1 -a ' . start_point)
            if index(current_ls, g:SANDPIT_FILENAME) != -1 && ignore_count_ <= 0
                break 
            endif
            let l:ignore_count_ -= 1
            let l:start_point = start_point . '../'
        endfor
        return trim(system("realpath " . start_point))
    endfunction

    function! FindWithinVerticalRange(...)
        let l:ignore_count = 0
        let l:vertical_range = 3
        if a:0 >= 1 | let l:pattern = a:1 | else 
            echo "Did not supply a pattern to search for."
            return
        endif
        if a:0 >= 2 | let l:ignore_count = a:2 | endif
        if a:0 >= 3 | let vertical_range = a:3 | endif
        if a:0 >= 4 
            echo "Too many arguments."
            return
        endif

        let l:start_point = GetStartPosition(ignore_count, vertical_range)
        let l:start_point_ = reverse(split(l:start_point, "/"))[0]

        let l:find_matches = systemlist('find $(realpath ' . start_point . ')' .
            \ ' -maxdepth ' . (vertical_range * 2) .
            \ ' -name ' . '*' . shellescape(l:pattern) . '*' .
            \ ' ' . g:FIND_IGNORES .
            \ ' -print')

        if empty(find_matches)
            echo "No matches found."
            return
        endif

        let l:matches_ = []
        for l:match in find_matches
            let l:match_parts = split(match, '/')
            let l:match_directory = match_parts[len(match_parts) - 2]
            let l:match_filename = match_parts[len(match_parts) - 1]
            call add(matches_, { 'filename': trim(system("realpath " . match)),
                \ 'module': l:start_point_ . "/~/" . match_directory . '/' . match_filename, 'text': match })
        endfor
        call setloclist(0, matches_, 'r')
        
        call ExchangeCurrentBufferWithLocationList()
    endfunction
    command! -nargs=* F call FindWithinVerticalRange(<f-args>)

    function! Find(pattern)
        let find_matches = systemlist('find .' . 
            \ ' -name ' . shellescape(a:pattern) .
            \ ' ' . g:FIND_IGNORES .
            \ ' -print')
        call append(line('.') - 1, find_matches)
    endfunction
    command! -nargs=* Find call Find(<f-args>)

    let g:GREP_EXCLUDES = join(['--exclude-dir=.git',
        \ '--exclude-dir=node_modules',
        \ '--exclude-dir=target --exclude-dir=build',
        \ '--exclude-dir=plugin --exclude=' . g:SANDPIT_FILENAME], ' ')

    function! GrepWithinVerticalRange(...)
        let l:ignore_count = 0
        let l:vertical_range = 3
        if a:0 >= 1 | let l:pattern = a:1 | else 
            echo "Did not supply a pattern to search for."
            return
        endif
        if a:0 >= 2 | let l:ignore_count = a:2 | endif
        if a:0 >= 3 | let l:vertical_range = a:3 | endif
        if a:0 >= 4 
            echo "Too many arguments."
            return
        endif

        let l:start_point = GetStartPosition(ignore_count, vertical_range)
        let l:start_point_ = reverse(split(l:start_point, "/"))[0]

        let l:grep_matches = systemlist('grep ' . shellescape(l:pattern) .
            \ ' ' . g:GREP_EXCLUDES .
            \ ' -I -n -r $(realpath ' . start_point . ')')

        if empty(grep_matches)
            echo "No matches found."
            return
        endif

        let l:matches_ = []
        for l:match in grep_matches
            let l:filepath = matchstr(match, '^[^:]*')
            let l:line_number = matchstr(match, ':\d*:')
            let l:line_number = line_number[1 : len(line_number) - 2]
            let l:code_glimps = substitute(match, '^[^:]*:\d\+:\s*', '', '')

            let l:path_parts = split(filepath, '/')
            let l:file_directory = path_parts[len(path_parts) - 2]
            let l:file_name = path_parts[len(path_parts) - 1]

            call add(matches_, { 'filename': trim(system("realpath " . filepath)), 
                \ 'lnum': line_number, 'text': code_glimps,
                \ 'module': l:start_point_ . '/~/' . file_directory . '/' . file_name })
        endfor
        call setloclist(0, matches_, 'r')
        
        call ExchangeCurrentBufferWithLocationList()
    endfunction
    command! -nargs=* G call GrepWithinVerticalRange(<f-args>)

    function! Grep(pattern)
        let l:grep_matches = systemlist('grep' . shellescape(a:pattern) .
            \ ' ' . g:GREP_EXCLUDES .
            \ ' -I -n -r ' . start_point)
        call append(line('.') - 1, grep_matches)
    endfunction
    command! -nargs=* Grep call Grep(<f-args>)

    function! LocationListEnter()
        let l:location_list = getloclist(0)
        let l:selected_entry = l:location_list[line(".") - 1]
        exec "b " . l:selected_entry["bufnr"]
        exec l:selected_entry["lnum"]
    endfunction
    autocmd FileType qf nmap <buffer> <cr> :call LocationListEnter()<cr>

    nnoremap x "_x
    vnoremap x "_d

    function! ShiftRegistersUp()
        for register_index in reverse(range(2, 9))
            let l:below_register = register_index - 1
            call setreg(
                \ register_index, 
                \ getreg(below_register), 
                \ getregtype(below_register))
        endfor
        call setreg(1, '')
    endfunction
    nnoremap D :call ShiftRegistersUp()<cr>"1d

    function! ShiftRegistersDown()
        for register_index in range(1, 8)
            let l:above_register = register_index + 1
            call setreg(
                \ register_index, 
                \ getreg(above_register), 
                \ getregtype(above_register))
        endfor
        call setreg(9, '')
    endfunction
    nnoremap <leader>p "1p:call ShiftRegistersDown()<cr>
    nnoremap <leader>P "1P:call ShiftRegistersDown()<cr>
]])

vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, {})
vim.keymap.set("n", "<leader>d", vim.lsp.buf.declaration, {})
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, {})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = false,
})

vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = vim.api.nvim_create_augroup("float_diagnostic_cursor", { clear = true }),
    callback = function ()
        vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
    end
})

local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})
-- lspconfig.eslint.setup({})
lspconfig.tsserver.setup({})
lspconfig.rust_analyzer.setup({})
