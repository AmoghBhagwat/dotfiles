-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
        local out = vim.fn.system({
                'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo,
                lazypath
        })
        if vim.v.shell_error ~= 0 then
                vim.api.nvim_echo({
                        {'Failed to clone lazy.nvim:\n', 'ErrorMsg'},
                        {out, 'WarningMsg'},
                        {'\nPress any key to exit...'}
                }, true, {})
                vim.fn.getchar()
                os.exit(1)
        end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup({
        spec = {
                {
                        'nvim-treesitter/nvim-treesitter',
                        build = ':TSUpdate',
                        opts = {
                                ensure_installed = {
                                        'c', 'cpp', 'lua', 'vim', 'vimdoc', 'python'
                                },
                                sync_install = true,
                                highlight = { enable = true },
                                indent = { enable = true },
                        },
                },

                { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },

                {
                        'nvim-lualine/lualine.nvim',
                        dependencies = { 'nvim-tree/nvim-web-devicons' },
                },

                { 'junegunn/fzf' },
                { 'junegunn/fzf.vim' },

                { 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },

                -- LSP + completion
                { 'neovim/nvim-lspconfig' },
                { 'hrsh7th/nvim-cmp' },
                { 'hrsh7th/cmp-nvim-lsp' },

                { 'nvim-telescope/telescope.nvim' },

                checker = { enabled = true },
        }
})

------------------------------------------------------------
-- LSP (Neovim 0.11+)
------------------------------------------------------------

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('clangd', {
        cmd = { "clangd-20" },
        capabilities = capabilities,
})

vim.lsp.config('pyright', {
        capabilities = capabilities,
})

vim.lsp.enable("clangd")

------------------------------------------------------------
-- nvim-cmp
------------------------------------------------------------

local cmp = require('cmp')

cmp.setup({
        snippet = {
                expand = function(args)
                        vim.fn['vsnip#anonymous'](args.body)
                end,
        },

        completion = {
                completeopt = 'menu,menuone,noinsert',
        },

        mapping = {
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<Up>'] = cmp.mapping.select_prev_item(),
                ['<Down>'] = cmp.mapping.select_next_item(),
                ['<Esc>'] = cmp.mapping.close(),
                ['<CR>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                }),
        },

        sources = {
                { name = 'nvim_lsp' },
                { name = 'vsnip' },
                { name = 'buffer' },
        },
})

------------------------------------------------------------
-- UI / options
------------------------------------------------------------

require('lualine').setup()

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 8
vim.opt.expandtab = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.guicursor = 'n-v-c-i:block'

vim.cmd.colorscheme('catppuccin')

------------------------------------------------------------
-- Keymaps
------------------------------------------------------------

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.api.nvim_set_keymap('n', '<leader>fr', ':History<CR>', { noremap = true })

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)

------------------------------------------------------------
-- LSP keymaps (buffer-local)
------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP Actions',
        callback = function(ev)
                local opts = { buffer = ev.buf }

                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "gC", vim.lsp.buf.incoming_calls, opts)
        end,
})
