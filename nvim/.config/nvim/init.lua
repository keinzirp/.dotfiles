-- Options.
vim.g.mapleader = ","
vim.o.colorcolumn = "80"
vim.o.belloff = "all"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.number = true
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("state") .. "/undo"
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.mouse = "a"
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.updatetime = 300
vim.o.scrolloff = 4
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.virtualedit = "block"
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.jumpoptions = "stack"
vim.o.confirm = true
vim.o.title = true
vim.o.winminwidth = 5
vim.o.titlestring = "%t - nvim"
vim.o.termguicolors = true
if vim.fn.executable("rg") == 1 then
    vim.o.grepprg = "rg --vimgrep --smart-case"
    vim.o.grepformat = "%f:%l:%c:%m"
end
vim.opt.clipboard = "unnamedplus"
vim.o.laststatus = 3
function _G.statusline()
    local parts = { " %f%m%r%=" }
    local d = vim.diagnostic.count(0)
    local e = d[vim.diagnostic.severity.ERROR] or 0
    local w = d[vim.diagnostic.severity.WARN] or 0
    if e > 0 then table.insert(parts, "E:" .. e .. " ") end
    if w > 0 then table.insert(parts, "W:" .. w .. " ") end
    local branch = vim.b.gitsigns_head
    if branch and branch ~= "" then table.insert(parts, branch .. " ") end
    table.insert(parts, "%l:%c %p%% ")
    return table.concat(parts)
end

vim.o.statusline = "%!v:lua.statusline()"

-- Highlights.
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local hl = vim.api.nvim_set_hl
        hl(0, "Search", { fg = "#000000", bg = "#CCB800", bold = true })
        hl(0, "IncSearch", { fg = "#000000", bg = "#FFFF00", bold = true })

        hl(0, "BlinkCmpKindFunction", { fg = "#C586C0" })
        hl(0, "BlinkCmpKindMethod", { fg = "#C586C0" })
        hl(0, "BlinkCmpKindConstructor", { fg = "#C586C0" })
        hl(0, "BlinkCmpKindVariable", { fg = "#9CDCFE" })
        hl(0, "BlinkCmpKindField", { fg = "#9CDCFE" })
        hl(0, "BlinkCmpKindProperty", { fg = "#9CDCFE" })
        hl(0, "BlinkCmpKindClass", { fg = "#4EC9B0" })
        hl(0, "BlinkCmpKindInterface", { fg = "#4EC9B0" })
        hl(0, "BlinkCmpKindStruct", { fg = "#4EC9B0" })
        hl(0, "BlinkCmpKindEnum", { fg = "#4EC9B0" })
        hl(0, "BlinkCmpKindEnumMember", { fg = "#4FC1FF" })
        hl(0, "BlinkCmpKindModule", { fg = "#DCDCAA" })
        hl(0, "BlinkCmpKindKeyword", { fg = "#569CD6" })
        hl(0, "BlinkCmpKindText", { fg = "#D4D4D4" })
        hl(0, "BlinkCmpKindSnippet", { fg = "#CE9178" })
        hl(0, "BlinkCmpKindConstant", { fg = "#4FC1FF" })
        hl(0, "BlinkCmpKindValue", { fg = "#4FC1FF" })
        hl(0, "BlinkCmpKindOperator", { fg = "#D4D4D4" })
        hl(0, "BlinkCmpKindTypeParameter", { fg = "#4EC9B0" })
        hl(0, "BlinkCmpKindReference", { fg = "#D4D4D4" })
        hl(0, "BlinkCmpKindColor", { fg = "#D4D4D4" })
        hl(0, "BlinkCmpKindUnit", { fg = "#D4D4D4" })
        hl(0, "BlinkCmpKindFile", { fg = "#DCDCAA" })
        hl(0, "BlinkCmpKindFolder", { fg = "#DCDCAA" })
        hl(0, "BlinkCmpKindEvent", { fg = "#DCDCAA" })
    end
})

vim.cmd([[colorscheme lunaperche]])

-- Sessions.
local function session_path()
    local dir = vim.fn.stdpath("data") .. "/sessions"
    vim.fn.mkdir(dir, "p")
    local name = vim.fn.getcwd():gsub("/", "%%")
    return dir .. "/" .. name .. ".vim"
end

-- Autocmds.
vim.diagnostic.config({
    severity_sort = true,
    virtual_text = { severity = vim.diagnostic.severity.ERROR },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H"
        }
    }
})
vim.api.nvim_create_autocmd("FileType", {
    callback = function() vim.opt_local.formatoptions = "cqrnj" end
})
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank({ timeout = 200 }) end
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, opts)
    end
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        vim.cmd("mksession! " .. vim.fn.fnameescape(session_path()))
    end
})

-- Keymaps.
vim.keymap.set("n", "gC", function()
    local abs = vim.fn.expand("%:p")
    if abs == "" then
        vim.notify("No file name for current buffer", vim.log.levels.WARN)
        return
    end
    local rel = vim.fn.fnamemodify(abs, ":.")
    vim.fn.setreg("+", rel)
    vim.notify("Copied: " .. rel)
end, { desc = "Copy current file path to clipboard" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
vim.keymap.set("n", "[b", "<cmd>bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", function()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd("bprev")
    vim.api.nvim_buf_delete(buf, {})
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>to", "<cmd>tabonly<CR>",
    { desc = "Close other tabs" })

vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end,
    { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,
    { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist,
    { desc = "Diagnostics to quickfix" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist,
    { desc = "Diagnostics to loclist" })

vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "]Q", "<cmd>clast<CR>", { desc = "Last quickfix" })
vim.keymap.set("n", "[Q", "<cmd>cfirst<CR>", { desc = "First quickfix" })

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<leader>o", "o<Esc>0\"_D", { silent = true })
vim.keymap.set("n", "<leader>O", "O<Esc>0\"_D", { silent = true })

vim.keymap.set("n", "<leader>sr", function()
    local f = session_path()
    if vim.uv.fs_stat(f) then
        vim.cmd("source " .. vim.fn.fnameescape(f))
    else
        vim.notify("No session for " .. vim.fn.getcwd(), vim.log.levels.WARN)
    end
end, { desc = "Restore session" })

-- Plugins.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.config").setup({
                ensure_installed = {
                    "typescript", "tsx", "rust", "python", "graphql", "cpp",
                    "html", "css", "lua", "ruby", "json", "yaml", "toml",
                    "markdown", "bash", "svelte"
                },
                highlight = { enable = true },
                auto_install = true,
                incremental_selection = { enable = true },
                indent = { enable = true }
            })
        end
    }, {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            handlers = { graphql = function() end },
            ensure_installed = {
                "rust_analyzer", "pylsp", "ts_ls", "clangd",
                "cssls", "lua_ls", "svelte"
            }
        })
        vim.lsp.config('relay_lsp', {
            cmd = { "node", "node_modules/.bin/relay-compiler", "lsp" },
            filetypes = {
                "javascript", "javascriptreact", "typescript",
                "typescriptreact", "graphql"
            },
            root_markers = { "relay.config.json", "relay.config.js" }
        })
        vim.lsp.enable('relay_lsp')
    end
}, {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    config = function()
        require("blink.cmp").setup({
            keymap = {
                ["<C-space>"] = { "show" },
                ["<C-e>"] = { "cancel" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-b>"] = { "scroll_documentation_up" },
                ["<C-f>"] = { "scroll_documentation_down" }
            },
            completion = {
                trigger = { show_on_insert_on_trigger_character = false },
                documentation = { auto_show = true },
                list = {
                    selection = { preselect = false, auto_insert = false }
                },
                menu = {
                    draw = {
                        columns = {
                            { "kind" },
                            { "label", "label_description", gap = 1 }
                        }
                    }
                }
            },
            signature = { enabled = true }
        })
    end
}, {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
        { "<leader>ff", "<cmd>FzfLua files<cr>",     desc = "Find files" },
        { "<leader>fr", "<cmd>FzfLua resume<cr>",    desc = "Fzf resume" },
        { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep files" },
        {
            "<leader>fh",
            "<cmd>FzfLua helptags<cr>",
            desc = "Grep tags in help files"
        },
        { "<leader>ft", "<cmd>FzfLua btags<cr>",   desc = "Search buffer tags" },
        {
            "<leader>fb",
            "<cmd>FzfLua buffers<cr>",
            desc = "Search opened buffers"
        },
        { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Search keymaps" },
        {
            "<leader>fd",
            "<cmd>FzfLua diagnostics_document<cr>",
            desc = "Document diagnostics"
        }, {
        "<leader>fs",
        "<cmd>FzfLua lsp_document_symbols<cr>",
        desc = "Document symbols"
    },
        {
            "<leader>/",
            "<cmd>FzfLua grep_cword<cr>",
            desc = "Grep word under cursor"
        }, {
        "<leader>/",
        "<cmd>FzfLua grep_visual<cr>",
        mode = "v",
        desc = "Grep selection"
    }
    },
    opts = {
        "hide",
        winopts = { split = "belowright new", preview = { delay = 0 } },
        fzf_opts = {
            ['--history'] = vim.fn.stdpath("data") .. '/fzf-lua-history'
        },
        keymap = {
            fzf = {
                true,
                ["ctrl-q"] = "select-all+accept",
                ['ctrl-n'] = 'down',
                ['ctrl-p'] = 'up'
            }
        }
    }
}, { "echasnovski/mini.surround", event = "VeryLazy",                       opts = {} },
    { "tpope/vim-fugitive",        cmd = { "Git", "G", "Gdiff", "Gvdiffsplit" } },
    { "tpope/vim-sleuth" }, { "tpope/vim-abolish", event = "VeryLazy" }, {
    "juacker/git-link.nvim",
    keys = {
        {
            "<leader>gu",
            function()
                require("git-link.main").copy_line_url()
            end,
            desc = "Copy code link to clipboard",
            mode = { "n", "x" }
        }, {
        "<leader>go",
        function()
            require("git-link.main").open_line_url()
        end,
        desc = "Open code link in browser",
        mode = { "n", "x" }
    }
    }
}, {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { icons = { mappings = false } },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)"
        }
    }
}, {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
        local sign_chars = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "-" },
            topdelete = { text = "-" },
            changedelete = { text = "~" }
        }
        require("gitsigns").setup({
            signs = vim.tbl_extend("force", sign_chars,
                { untracked = { text = "?" } }),
            signs_staged = sign_chars,
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local function o(desc)
                    return { buffer = bufnr, desc = desc }
                end
                vim.keymap.set("n", "]c",
                    function()
                        gs.nav_hunk("next")
                    end, o("Next hunk"))
                vim.keymap.set("n", "[c",
                    function()
                        gs.nav_hunk("prev")
                    end, o("Previous hunk"))
                vim.keymap.set("n", "<leader>hs", gs.stage_hunk,
                    o("Stage hunk"))
                vim.keymap.set("v", "<leader>hs", function()
                    gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") }
                end, o("Stage selection"))
                vim.keymap.set("n", "<leader>hr", gs.reset_hunk,
                    o("Reset hunk"))
                vim.keymap.set("v", "<leader>hr", function()
                    gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") }
                end, o("Reset selection"))
                vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk,
                    o("Undo stage hunk"))
                vim.keymap.set("n", "<leader>hp", gs.preview_hunk,
                    o("Preview hunk"))
                vim.keymap.set("n", "<leader>hb",
                    function()
                        gs.blame_line({ full = true })
                    end, o("Blame line"))
            end
        })
    end
}, {
    "stevearc/conform.nvim",
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters_by_ft = {
                lua = { "lua-format", "stylua", stop_after_first = true },
                python = { "black" },
                ruby = { "rubocop" },
                javascript = { "biome-check", "biome-organize-imports" },
                javascriptreact = { "biome-check", "biome-organize-imports" },
                typescript = { "biome-check", "biome-organize-imports" },
                typescriptreact = { "biome-check", "biome-organize-imports" },
                cpp = { "clang-format" }
            },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or
                    vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 2000, lsp_format = "fallback" }
            end
        })
        vim.g.disable_autoformat = false
        vim.api.nvim_create_user_command("FormatToggle", function(args)
            if args.bang then
                vim.b.disable_autoformat = not vim.b.disable_autoformat
                print("Buffer autoformat: " ..
                    (vim.b.disable_autoformat and "off" or "on"))
            else
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                print("Global autoformat: " ..
                    (vim.g.disable_autoformat and "off" or "on"))
            end
        end, { desc = "Toggle autoformat-on-save", bang = true })
        vim.keymap.set("n", "<leader>tf", "<cmd>FormatToggle<CR>",
            { desc = "Toggle autoformat (global)" })
        vim.keymap.set("n", "<leader>fo", function()
            conform.format({ bufnr = vim.api.nvim_get_current_buf() })
        end, { desc = "Format buffer" })
    end
}, {
    'stevearc/oil.nvim',
    opts = {
        columns = { "icon", "permissions", "size", "mtime" },
        view_options = { show_hidden = true },
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        constrain_cursor = "name",
        watch_for_changes = true
    },
    keys = {
        { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
        {
            "g-",
            function()
                local width = math.floor(vim.o.columns / 3)
                vim.cmd("aboveleft " .. width .. "vsplit | Oil")
            end,
            desc = "Open parent directory in left vsplit"
        },
    }
}, { "chentoast/marks.nvim", event = "VeryLazy", opts = {} }, {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {}
}, { "echasnovski/mini.ai", event = "VeryLazy", opts = {} }, {
    "andyg/leap.nvim",
    url = "https://codeberg.org/andyg/leap.nvim",
    event = "VeryLazy",
    config = function()
        vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
        vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
    end
}
})
