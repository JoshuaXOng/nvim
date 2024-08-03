vim.cmd([[
    set ts=4 sw=4 expandtab smarttab autoindent
    set rnu nu foldmethod=indent hls
    set path=** wildmenu wildignore=**/.git/**,**/node_modules/**,**/target/**,**/build/**
    set shortmess-=S hidden nobackup nowritebackup
    let mapleader = " "
    nmap <Space> <Nop>
    nmap t gt
    nmap T gT
    nmap <Tab> :! 
    nmap <Leader>; :r! 
    nmap j gj
    nmap k gk
    tmap <C-[> <C-\><C-n>
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
