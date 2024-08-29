vim.cmd([[
    set ts=4 sw=4 expandtab smarttab autoindent
    set rnu nu foldmethod=indent hls
    set path=** wildmenu wildignore=**/.git/**,**/node_modules/**,**/target/**,**/build/** cpoptions+=m
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
