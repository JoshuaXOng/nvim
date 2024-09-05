vim.cmd([[
    set ts=4 sw=4 expandtab smarttab autoindent
    set rnu nu foldmethod=indent hls
    set autochdir path=** wildmenu wildignore=**/.git/**,**/node_modules/**,**/target/**,**/build/**
    let g:netrw_keepdir = 0
    set shortmess-=S hidden nobackup nowritebackup
    set statusline=%{expand('%:p')}%{'\ \ '.winnr()}
    let mapleader = " "
    nmap <space> <nop>
    nmap <leader>l gt
    nmap <leader>h gT
    nmap ; :! 
    nmap <leader>e :execute 'r! sh -c "' . getline('.') . '"'<cr>
    nmap <leader>; :r! 
    nmap j gj
    nmap k gk
    tmap <c-[> <c-\><c-n>
    nmap <leader>w <c-w>
    command! Tn tabnew 
    command! -nargs=1 Tm tabmove <args>
    cmap <c-l> <c-r>0

    function! GetBufferDirectory()
        let @0 = expand('%:p')
    endfunction
    command! Bd call GetBufferDirectory()

    function! HighlightWord()
        let l:cword = expand('<cword>')
        call clearmatches()
        execute 'match Search /\<\V' . l:cword . '\>/'
    endfunction
    nnoremap <leader>f :call HighlightWord()<cr>

    function! SyncWorkingDirectory()
        let l:parent_path = expand('%:p:h')
        if isdirectory(l:parent_path)
            execute 'cd ' . fnameescape(l:parent_path)
        endif
    endfunction
    nmap <leader>s :call SyncWorkingDirectory()<cr>

    function! ExchangeWindowBuffers()
        let current_window = winnr()
        let current_buffer = bufnr("%")
        let previous_window = winnr("#")
        let previous_buffer = winbufnr(previous_window)
  
        exec  previous_window . " wincmd w" . " | " .
            \ "buffer " . current_buffer . " | " .
            \ current_window ." wincmd w" . " | " .
            \ "buffer " . previous_buffer

        q

        wincmd p  
    endfunction

    function! ExchangeCurrentBufferWithQuickfix()
        copen
        call ExchangeWindowBuffers()
    endfunction

    let g:SANDPIT_FILENAME = ".sandpit"
    let g:FIND_IGNORES = join(['-not -path **/.git/**',
        \ '-not -path **/node_modules/**',
        \ '-not -path **/target/**',
        \ '-not -path **/build/**',
        \ '-not -path **/plugin/**'], ' ')

    function! GetStartPosition(ignore_count, vertical_range)
        let l:ignore_count_ = a:ignore_count
        let l:start_point = './'
        for _ in range(1, a:vertical_range)
            let l:current_ls = systemlist('ls -1 -a ' . start_point)
            if index(current_ls, g:SANDPIT_FILENAME) != -1 && ignore_count_ == 0
                break 
            endif
            let l:ignore_count_ -= 1
            let l:start_point = start_point . '../'
        endfor
        return start_point
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

        let l:find_matches = systemlist('find ' . start_point .
            \ ' -maxdepth ' . (vertical_range * 2) .
            \ ' -name ' . shellescape(l:pattern) .
            \ ' ' . g:FIND_IGNORES .
            \ ' -print')

        if empty(find_matches)
            echo "No matches found."
            return
        endif

        let l:matches_ = []
        for l:match in find_matches
            call add(matches_, { 'filename': match })
        endfor
        call setqflist(matches_, 'r')
        
        call ExchangeCurrentBufferWithQuickfix()
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

        let l:grep_matches = systemlist('grep ' . shellescape(l:pattern) .
            \ ' ' . g:GREP_EXCLUDES .
            \ ' -I -n -r ' . start_point)

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
            call add(matches_, { 'filename': filepath, 'lnum': line_number, 'text': code_glimps })
        endfor
        call setqflist(matches_, 'r')
        
        call ExchangeCurrentBufferWithQuickfix()
    endfunction
    command! -nargs=* G call GrepWithinVerticalRange(<f-args>)

    function! Grep(pattern)
        let l:grep_matches = systemlist('grep' . shellescape(a:pattern) .
            \ ' ' . g:GREP_EXCLUDES .
            \ ' -I -n -r ' . start_point)
        call append(line('.') - 1, grep_matches)
    endfunction
    command! -nargs=* Grep call Grep(<f-args>)
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
