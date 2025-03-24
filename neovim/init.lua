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
            {'Failed to clone lazy.nvim:\n', 'ErrorMsg'}, {out, 'WarningMsg'},
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
            config = function()
                local configs = require('nvim-treesitter.configs')

                configs.setup({
                    ensure_installed = {
                        'c', 'cpp', 'lua', 'vim', 'vimdoc', 'python'
                    },
                    sync_install = true,
                    highlight = {enable = true},
                    indent = {enable = true}
                })
            end
        },
        {'catppuccin/nvim', name = 'catppuccin', priority = 1000},
        {
            'nvim-lualine/lualine.nvim',
            dependencies = {'nvim-tree/nvim-web-devicons'},
            options = {icons_enabled = true, theme = 'dracula'}
        },
        {'junegunn/fzf'},
        {'junegunn/fzf.vim'},
        {'windwp/nvim-autopairs', event = 'InsertEnter', config = true},
        {'github/copilot.vim'},
        {'neovim/nvim-lspconfig'},
        {'hrsh7th/nvim-cmp'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'nvim-telescope/telescope.nvim'},
        -- Configure any other settings here. See the documentation for more details.
        -- colorscheme that will be used when installing plugins.
        -- install = {colorscheme = {'habamax'}},
        checker = {enabled = true}
    }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

local servers = {
    'clangd', 'pyright'
}

for _, server in ipairs(servers) do
    lspconfig[server].setup {
        capabilities = capabilities
    }
end

local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
        end
    },
    completion = {
        completeopt = 'menu,menuone,noinsert'
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
            select = true
        })
    },
    sources = {
        {name = 'nvim_lsp'}, {name = 'vsnip'}, {name = 'buffer'}
    }
})

require('nvim-autopairs').setup()

require('lualine').setup()
require'lspconfig'.clangd.setup{}

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.guicursor = 'n-v-c-i:block'
vim.cmd.colorscheme 'catppuccin'

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.api.nvim_set_keymap('n', '<leader>fr', ':History<CR>', {noremap = true})

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {noremap = true})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {noremap = true})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {noremap = true})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {noremap = true})

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP Actions',
    callback = function()
        local bufmap = function(mode, lhs, rhs)
            local opts = {buffer=true}
            vim.keymap.set(mode, lhs, rhs, opts)
        end

        bufmap('n', 'K', '<cmd> lua vim.lsp.buf.hover()<cr>')
        bufmap('n', 'gd', '<cmd> lua vim.lsp.buf.definition()<cr>')
        bufmap('n', 'gD', '<cmd> lua vim.lsp.buf.declaration()<cr>')
        bufmap('n', '<F2>', '<cmd> lua vim.lsp.buf.rename()<cr>')
    end
})
