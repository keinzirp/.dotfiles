-- Options.
vim.g.mapleader = ","
vim.o.colorcolumn = "80"
vim.o.belloff = "all"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("state") .. "/undo"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.mouse = "a"
vim.o.list = true
vim.o.listchars = "trail:·,nbsp:␣"
vim.o.updatetime = 300
vim.o.scrolloff = 4
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.virtualedit = "block"
vim.o.wrap = true
vim.o.breakindent = false
vim.o.linebreak = true
vim.o.jumpoptions = "stack"
vim.o.confirm = true
vim.o.title = true
vim.o.winminwidth = 5
vim.o.titlestring = "%F - nvim"
vim.o.termguicolors = true
if vim.fn.executable("rg") == 1 then
	vim.o.grepprg = "rg --vimgrep --smart-case"
	vim.o.grepformat = "%f:%l:%c:%m"
end
vim.opt.clipboard = "unnamedplus"
vim.o.laststatus = 3
vim.o.statusline = " %f%m%r%=%l:%c %p%% "

-- Highlights.
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		local hl = vim.api.nvim_set_hl
		hl(0, "Search", { fg = "#000000", bg = "#CCB800", bold = true })
		hl(0, "IncSearch", { fg = "#000000", bg = "#FFFF00", bold = true })
		hl(0, "ColorColumn", { link = "CursorLine" })
		hl(0, "WinSeparator", { fg = "#0f0d0b", bg = "#0f0d0b" })

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
	end,
})

-- Autocmds.
vim.diagnostic.config({
	severity_sort = true,
	virtual_text = { severity = vim.diagnostic.severity.ERROR },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		vim.opt_local.formatoptions = "cqrnj"
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ timeout = 200 })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
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
	end,
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

vim.api.nvim_create_user_command("CdRoot", function()
	local root = vim.fs.root(0, { ".git", ".jj" })
	if not root then
		vim.notify("No project root found", vim.log.levels.WARN)
		return
	end
	vim.cmd("cd " .. vim.fn.fnameescape(root))
end, { desc = "Change working directory to project root" })
vim.keymap.set("n", "<leader>cR", "<cmd>CdRoot<CR>", { desc = "Change to project root" })

vim.keymap.set("n", "<C-Left>", "<C-w><", { desc = "Decrease width" })
vim.keymap.set("n", "<C-Right>", "<C-w>>", { desc = "Increase width" })
vim.keymap.set("n", "<C-Up>", "<C-w>+", { desc = "Increase height" })
vim.keymap.set("n", "<C-Down>", "<C-w>-", { desc = "Decrease height" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
vim.keymap.set("n", "[b", "<cmd>bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader><Tab>", "<C-^>", { desc = "Alternate buffer" })
vim.keymap.set("n", "<leader>bd", function()
	local buf = vim.api.nvim_get_current_buf()
	vim.cmd("bprev")
	vim.api.nvim_buf_delete(buf, {})
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "Close other tabs" })
vim.keymap.set("n", "<C-w><C-]>", function()
	vim.cmd("vertical stag " .. vim.fn.expand("<cword>"))
end, { silent = true })

-- Navigate diagnostics.
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Navigate quickfix.
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "]Q", "<cmd>clast<CR>", { desc = "Last quickfix" })
vim.keymap.set("n", "[Q", "<cmd>cfirst<CR>", { desc = "First quickfix" })

-- Navigate virtual lines.
vim.keymap.set({ "n", "v" }, "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true })
vim.keymap.set({ "n", "v" }, "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true })

-- Center after page scroll.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Move lines.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("n", "J", "mzJ`z")

-- Insert newlines from normal mode.
vim.keymap.set("n", "<leader>o", 'o<Esc>0"_D', { silent = true })
vim.keymap.set("n", "<leader>O", 'O<Esc>0"_D', { silent = true })

-- Plugins.
vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.tohtml")
vim.keymap.set("n", "<leader>u", require("undotree").open)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			require("mason").setup()
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})
			require("mason-lspconfig").setup({
				ensure_installed = {
					"rust_analyzer",
					"pylsp",
					"ts_ls",
					"clangd",
					"cssls",
					"lua_ls",
					"svelte",
				},
			})
			vim.lsp.config("relay_lsp", {
				cmd = { "node", "node_modules/.bin/relay-compiler", "lsp" },
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"graphql",
				},
				root_markers = { "relay.config.json", "relay.config.js" },
			})
			-- vim.lsp.enable("relay_lsp")

			vim.lsp.config("nushell", {
				cmd = { "nu", "--lsp" },
				filetypes = { "nu" },
				root_dir = function(bufnr, on_dir)
					on_dir(vim.fs.root(bufnr, { ".git", ".jj" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
				end,
			})
			vim.lsp.enable("nushell")
		end,
	},
	{
		"saghen/blink.cmp",
		version = "*",
		event = "InsertEnter",
		config = function()
			local function in_comment()
				local ok, node = pcall(vim.treesitter.get_node)
				return ok and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
			end

			require("blink.cmp").setup({
				enabled = function()
					return not in_comment()
				end,
				keymap = {
					["<C-space>"] = { "show" },
					["<C-e>"] = { "cancel" },
					["<CR>"] = { "accept", "fallback" },
					["<C-b>"] = { "scroll_documentation_up" },
					["<C-f>"] = { "scroll_documentation_down" },
				},
				completion = {
					trigger = { show_on_insert_on_trigger_character = true },
					documentation = { auto_show = true },
					list = {
						selection = { preselect = true, auto_insert = false },
					},
					menu = {
						draw = {
							columns = {
								{ "kind" },
								{ "label", "label_description", gap = 1 },
							},
						},
					},
				},
				signature = { enabled = true },
			})
		end,
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { { "folke/trouble.nvim", lazy = true } },
		cmd = "FzfLua",
		keys = {
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
			{ "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Fzf resume" },
			{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep files" },
			{
				"<leader>fh",
				"<cmd>FzfLua helptags<cr>",
				desc = "Grep tags in help files",
			},
			{ "<leader>ft", "<cmd>FzfLua btags<cr>", desc = "Search buffer tags" },
			{
				"<leader>fb",
				"<cmd>FzfLua buffers<cr>",
				desc = "Search opened buffers",
			},
			{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Search keymaps" },
			{
				"<leader>fd",
				"<cmd>FzfLua diagnostics_document<cr>",
				desc = "Document diagnostics",
			},
			{
				"<leader>fs",
				"<cmd>FzfLua lsp_document_symbols<cr>",
				desc = "Document symbols",
			},
			{
				"<leader>/",
				"<cmd>FzfLua grep_cword<cr>",
				desc = "Grep word under cursor",
			},
			{
				"<leader>/",
				"<cmd>FzfLua grep_visual<cr>",
				mode = "v",
				desc = "Grep selection",
			},
			{
				"<leader>fR",
				"<cmd>FzfLua lsp_references<cr>",
				desc = "References",
			},
			{
				"<leader>fS",
				"<cmd>FzfLua lsp_workspace_symbols<cr>",
				desc = "Workspace symbols",
			},
			{
				"<leader>fi",
				"<cmd>FzfLua lsp_incoming_calls<cr>",
				desc = "Incoming calls",
			},
			{
				"<leader>fO",
				"<cmd>FzfLua lsp_outgoing_calls<cr>",
				desc = "Outgoing calls",
			},
		},

		config = function()
			local fzf_lua = require("fzf-lua")
			local actions = require("fzf-lua.actions")
			local open_in_trouble = require("trouble.sources.fzf").actions.open
			local function parse_file_query(query)
				if type(query) ~= "string" or query == "" then
					return
				end
				local path, line, col = query:match("^(.-):(%d+):(%d+)$")
				if path and path ~= "" then
					return path, tonumber(line), tonumber(col)
				end
				path, line = query:match("^(.-):(%d+)$")
				if path and path ~= "" then
					return path, tonumber(line)
				end
			end
			local function jump_query_col()
				local _, _, col = parse_file_query(fzf_lua.get_info().query)
				if not col then
					return
				end
				local pos = vim.api.nvim_win_get_cursor(0)
				pcall(vim.api.nvim_win_set_cursor, 0, { pos[1], math.max(col - 1, 0) })
				vim.cmd("normal! zvzz")
			end
			local function with_query_col(action)
				return function(selected, opts)
					action(selected, opts)
					jump_query_col()
				end
			end
			fzf_lua.setup({
				"hide",
				formatter = { name = "path.filename_first", v = 2 },
				winopts = {
					height = 0.85,
					width = 0.85,
					preview = { delay = 0 },
				},
				previewers = {
					builtin = {
						title_fnamemodify = function(s)
							return vim.fn.fnamemodify(s, ":.")
						end,
					},
				},
				fzf_opts = {
					["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
				},
				keymap = {
					fzf = {
						true,
						["ctrl-q"] = "select-all+accept",
						["ctrl-n"] = "down",
						["ctrl-p"] = "up",
					},
				},
				actions = {
					files = {
						true,
						["enter"] = with_query_col(actions.file_edit_or_qf),
						["ctrl-s"] = with_query_col(actions.file_split),
						["ctrl-v"] = with_query_col(actions.file_vsplit),
						["ctrl-t"] = open_in_trouble,
					},
				},
				grep = {
					actions = {
						["ctrl-g"] = false,
						["ctrl-o"] = { actions.grep_lgrep },
						["ctrl-t"] = open_in_trouble,
					},
				},
				files = {
					line_query = function(query)
						local path, line = parse_file_query(query)
						return line, path
					end,
				},
			})
		end,
	},
	{ "echasnovski/mini.surround", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.comment", event = "VeryLazy", opts = {} },
	{ "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiff", "Gvdiffsplit" } },
	{ "tpope/vim-sleuth" },
	{ "tpope/vim-abolish", event = "VeryLazy" },
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			icons = {
				mappings = false,
				rules = false,
				breadcrumb = ">",
				separator = "->",
				group = "+",
				ellipsis = "...",
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			local sign_chars = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "-" },
				topdelete = { text = "-" },
				changedelete = { text = "~" },
			}
			require("gitsigns").setup({
				signs = vim.tbl_extend("force", sign_chars, { untracked = { text = "?" } }),
				signs_staged = sign_chars,
				on_attach = function(bufnr)
					local gs = require("gitsigns")
					local function o(desc)
						return { buffer = bufnr, desc = desc }
					end
					vim.keymap.set("n", "]c", function()
						gs.nav_hunk("next")
					end, o("Next hunk"))
					vim.keymap.set("n", "[c", function()
						gs.nav_hunk("prev")
					end, o("Previous hunk"))
					vim.keymap.set("n", "<leader>hs", gs.stage_hunk, o("Stage hunk"))
					vim.keymap.set("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, o("Stage selection"))
					vim.keymap.set("n", "<leader>hr", gs.reset_hunk, o("Reset hunk"))
					vim.keymap.set("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, o("Reset selection"))
					vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, o("Undo stage hunk"))
					vim.keymap.set("n", "<leader>hp", gs.preview_hunk, o("Preview hunk"))
					vim.keymap.set("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end, o("Blame line"))
				end,
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			local conform = require("conform")
			local function format_opts(bufnr)
				if vim.bo[bufnr].filetype == "svelte" then
					return
				end
				return { timeout_ms = 1000, lsp_format = "fallback" }
			end
			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black" },
					ruby = { "rubyfmt" },
					javascript = { "biome" },
					javascriptreact = { "biome" },
					typescript = { "biome" },
					typescriptreact = { "biome" },
					json = { "biome" },
					jsonc = { "biome" },
					css = { "biome" },
					cpp = { "clang-format" },
					sql = { "sql_formatter" },
				},
				format_on_save = format_opts,
			})
			vim.keymap.set("n", "<leader>fo", function()
				conform.format({ bufnr = vim.api.nvim_get_current_buf() })
			end, { desc = "Format buffer" })
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters.biomejs.cmd = "biome"
			lint.linters_by_ft = {
				javascript = { "biomejs" },
				javascriptreact = { "biomejs" },
				typescript = { "biomejs" },
				typescriptreact = { "biomejs" },
				json = { "biomejs" },
				jsonc = { "biomejs" },
				css = { "biomejs" },
				sh = { "shellcheck" },
				zsh = { "shellcheck" },
			}
			vim.api.nvim_create_autocmd("BufWritePost", {
				callback = function(args)
					if vim.bo[args.buf].buftype ~= "" or vim.api.nvim_buf_get_name(args.buf) == "" then
						return
					end
					lint.try_lint(nil, { ignore_errors = true })
				end,
			})
		end,
	},
	{
		"stevearc/oil.nvim",
		opts = {
			columns = { "permissions", "size", "mtime" },
			view_options = { show_hidden = true },
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			constrain_cursor = "name",
			watch_for_changes = true,
		},
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
			{
				"g-",
				function()
					local width = math.floor(vim.o.columns / 3)
					vim.cmd("aboveleft " .. width .. "vsplit | Oil")
				end,
				desc = "Open parent directory in left vsplit",
			},
		},
	},
	{ "chentoast/marks.nvim", event = "VeryLazy", opts = {} },
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		opts = {},
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		init = function()
			local function match_normal_bg()
				vim.api.nvim_set_hl(0, "TroubleNormal", { link = "Normal" })
				vim.api.nvim_set_hl(0, "TroubleNormalNC", { link = "Normal" })
			end
			match_normal_bg()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = match_normal_bg })
		end,
		opts = {
			focus = false,
			icons = {
				indent = {
					top = "  ",
					middle = "  ",
					last = "  ",
					fold_open = "v ",
					fold_closed = "> ",
					ws = "  ",
				},
				folder_closed = "",
				folder_open = "",
				kinds = setmetatable({}, {
					__index = function()
						return ""
					end,
				}),
			},
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (workspace)" },
			{ "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
			{ "<leader>xr", "<cmd>Trouble lsp toggle win.position=right<cr>", desc = "LSP refs/defs" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
			{ "]t", "<cmd>Trouble next jump=true<cr>", desc = "Next Trouble item" },
			{ "[t", "<cmd>Trouble prev jump=true<cr>", desc = "Previous Trouble item" },
		},
	},
	{ "echasnovski/mini.ai", event = "VeryLazy", opts = {} },
	{
		"wtfox/jellybeans.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			vim.cmd([[colorscheme jellybeans-warm]])
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		opts = {
			picker = {},
			indent = {
				animate = { enabled = false },
				indent = { enabled = false },
				scope = { enabled = true },
			},
			gitbrowse = {},
			scratch = {},
		},
		keys = {
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Open scratch buffer",
			},
			{
				"<leader>s",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select scratch buffer",
			},
			{
				"<leader>gb",
				function()
					Snacks.gitbrowse()
				end,
				desc = "Git browse",
			},
			{
				"<leader>gB",
				function()
					Snacks.gitbrowse({
						open = function(url)
							vim.fn.setreg("+", url)
							vim.notify("Copied: " .. url)
						end,
					})
				end,
				desc = "Copy git browse URL",
			},
		},
	},
	{
		"folke/persistence.nvim",
		lazy = false,
		config = function()
			local persistence = require("persistence")
			persistence.setup()
			vim.keymap.set("n", "<leader>qs", function()
				persistence.load()
			end, { desc = "Load session" })

			vim.keymap.set("n", "<leader>qS", function()
				persistence.select()
			end, { desc = "Select session" })

			vim.keymap.set("n", "<leader>ql", function()
				persistence.load({ last = true })
			end, { desc = "Last session" })

			vim.keymap.set("n", "<leader>qd", function()
				persistence.stop()
			end, { desc = "Stop session" })
		end,
	},
	{
		"mikavilpas/yazi.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = {
			{ "nvim-lua/plenary.nvim", lazy = true },
		},
		keys = {
			{
				"<leader>-",
				mode = { "n", "v" },
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>cw",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				"<leader>cr",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		opts = {
			open_for_directories = true,
			keymaps = {
				show_help = "<f1>",
			},
		},
		init = function()
			vim.g.loaded_netrwPlugin = 1
		end,
	},
	{
		"lowitea/aw-watcher.nvim",
		opts = {
			aw_server = {
				host = "127.0.0.1",
				port = 5600,
			},
		},
		config = function(_, opts)
			local aw = require("aw_watcher")
			aw.setup(opts)
			local client = aw.__private.aw
			client.__post = function(self, url, data)
				local body = vim.fn.json_encode(data)
				local args = { "-X", "POST", url, "-H", "Content-Type: application/json", "--data-raw", body }
				local handle
				handle = vim.loop.spawn("curl", { args = args, verbatim = false }, function(code)
					self.connected = code == 0
					if handle and not handle:is_closing() then
						handle:close()
					end
				end)
			end
		end,
	},
})
