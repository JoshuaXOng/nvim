vim.cmd([[
    set ts=4 sw=4 expandtab smarttab autoindent
    set rnu nu foldmethod=indent hls
    set autochdir path=** wildmenu wildignore=**/.git/**,**/node_modules/**,**/target/**,**/build/** wildoptions=pum
    let g:netrw_keepdir = 0
    set shortmess-=S hidden nobackup nowritebackup
    set statusline=%{winnr()}%{'\ '.expand('%:p')}
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

    function! Bd()
        let @0 = expand('%:p')
    endfunction
    command! Bd call Bd()

    function! Fw()
        let l:cword = expand('<cword>')
        call clearmatches()
        execute 'match Search /\<\V' . l:cword . '\>/'
    endfunction
    nnoremap <leader>f :call Fw()<cr>

    function! SyncWd()
        let l:parent_path = expand('%:p:h')
        if isdirectory(l:parent_path)
            execute 'cd ' . fnameescape(l:parent_path)
        endif
    endfunction
    nmap <leader>s :call SyncWd()<cr>

    function! ExchangeCurrentBufferWithQuickfix()
        copen

        let current_window = winnr()
        let current_buffer = bufnr("%")
        let previous_window = winnr("#")
        let previous_buffer = winbufnr(previous_window)
  
        exec  previous_window . " wincmd w" . "|" .
            \ "buffer " . current_buffer . "|" .
            \ current_window ." wincmd w" . "|" .
            \ "buffer " . previous_buffer

        q

        wincmd p  
    endfunction

    let g:sandpit_filename = ".sandpit"
    let g:find_ignores = join(['-not -path **/.git/**',
        \ '-not -path **/node_modules/**',
        \ '-not -path **/target/**',
        \ '-not -path **/build/**',
        \ '-not -path **/plugin/**'], ' ')

    function! Fr(...)
        let l:ignore_count = 0
        let l:range_ = 3
        if a:0 >= 1
            let l:pattern = a:1
        else 
            echo "Did not supply a pattern to search for."
            return
        endif
        if a:0 >= 2
            let l:ignore_count = a:2
        endif
        if a:0 >= 3
            let l:range_ = a:3
        endif

        let start_point_ = './'
        for _ in range(1, l:range_)
            let current_ls = systemlist('ls -1 -a ' . start_point_)
            if index(current_ls, g:sandpit_filename) != -1 && l:ignore_count == 0
                break 
            endif
            let l:ignore_count -= 1
            let start_point_ = start_point_ . '../'
        endfor

        let start_point = join(repeat([".."], l:range_), '/')
        let matches = systemlist('find ' . start_point_ .
            \ ' -maxdepth ' . (l:range_ * 2) .
            \ ' -name ' . shellescape(l:pattern) .
            \ ' ' . g:find_ignores .
            \ ' -print')

        if empty(matches)
            echo "No matches found."
            return
        endif

        let matches_ = []
        for match in matches
            call add(matches_, { 'filename': match, 'lnum': 1, 'col': 1 })
        endfor
        call setqflist(matches_, 'r')
        
        call ExchangeCurrentBufferWithQuickfix()
    endfunction
    command! -nargs=* Fr call Fr(<f-args>)

    function! F(pattern)
        let matches = systemlist('find .' . 
            \ ' -name ' . shellescape(a:pattern) .
            \ ' ' . g:find_ignores .
            \ ' -print')
        call append(line('.') - 1, matches)
    endfunction
    command! -nargs=* F call F(<f-args>)

    function! G(pattern)
        let matches = systemlist('grep' .
            \ ' --exclude-dir=.git --exclude-dir=node_modules' .
            \ ' --exclude-dir=target --exclude-dir=build' .
            \ ' --exclude-dir=plugin --exclude=' . g:sandpit_filename .
            \ '-I -r ' . a:pattern)
        call append(line('.') - 1, matches)
    endfunction
    command! -nargs=* G call G(<f-args>)
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
