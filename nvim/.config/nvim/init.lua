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
	if e > 0 then
		table.insert(parts, "E:" .. e .. " ")
	end
	if w > 0 then
		table.insert(parts, "W:" .. w .. " ")
	end
	local branch = vim.b.gitsigns_head
	if branch and branch ~= "" then
		table.insert(parts, branch .. " ")
	end
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
	pattern = {
		"typescript",
		"tsx",
		"javascript",
		"javascriptreact",
		"svelte",
		"html",
		"css",
		"lua",
		"rust",
		"python",
		"graphql",
		"cpp",
		"ruby",
		"json",
		"yaml",
		"toml",
		"markdown",
		"bash",
		"nushell",
	},
	callback = function()
		vim.treesitter.start()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				handlers = { graphql = function() end },
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
					on_dir(vim.fs.root(bufnr, { ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
				end,
			})
		end,
	},
	{
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
			local actions = require("fzf-lua.actions")
			local open_in_trouble = require("trouble.sources.fzf").actions.open
			require("fzf-lua").setup({
				"hide",
				winopts = { height = 0.85, width = 0.85, preview = { delay = 0 } },
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
			})
		end,
	},
	{ "echasnovski/mini.surround", event = "VeryLazy", opts = {} },
	{ "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiff", "Gvdiffsplit" } },
	{ "tpope/vim-sleuth" },
	{ "tpope/vim-abolish", event = "VeryLazy" },
	{
		"airblade/vim-rooter",
		lazy = false,
		init = function()
			vim.g.rooter_silent_chdir = 1
			vim.g.rooter_patterns = { ".git" }
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = function()
			local keys = { C = "<C-", M = "<M-", D = "<D-", S = "<S-" }
			for _, k in ipairs({
				"Up",
				"Down",
				"Left",
				"Right",
				"CR",
				"Esc",
				"NL",
				"BS",
				"Space",
				"Tab",
				"ScrollWheelDown",
				"ScrollWheelUp",
			}) do
				keys[k] = "<" .. k .. "> "
			end
			for i = 1, 12 do
				keys["F" .. i] = "<F" .. i .. ">"
			end
			return {
				icons = {
					mappings = false,
					rules = false,
					breadcrumb = ">",
					separator = "->",
					group = "+",
					ellipsis = "...",
					keys = keys,
				},
			}
		end,
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
			conform.setup({
				formatters_by_ft = {
					lua = { "lua-format", "stylua", stop_after_first = true },
					python = { "black" },
					ruby = { "rubocop" },
					javascript = { "biome-check" },
					javascriptreact = { "biome-check" },
					typescript = { "biome-check" },
					typescriptreact = { "biome-check" },
					-- svelte = { "biome-check" },
					cpp = { "clang-format" },
					sql = { "sql_formatter" },
				},
				format_after_save = function(bufnr)
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					if vim.bo[bufnr].filetype == "svelte" then
						return
					end
					return { lsp_format = "fallback" }
				end,
			})
			vim.g.disable_autoformat = false
			vim.api.nvim_create_user_command("FormatToggle", function(args)
				if args.bang then
					vim.b.disable_autoformat = not vim.b.disable_autoformat
					print("Buffer autoformat: " .. (vim.b.disable_autoformat and "off" or "on"))
				else
					vim.g.disable_autoformat = not vim.g.disable_autoformat
					print("Global autoformat: " .. (vim.g.disable_autoformat and "off" or "on"))
				end
			end, { desc = "Toggle autoformat-on-save", bang = true })
			vim.keymap.set("n", "<leader>tf", "<cmd>FormatToggle<CR>", { desc = "Toggle autoformat (global)" })
			vim.keymap.set("n", "<leader>fo", function()
				conform.format({ bufnr = vim.api.nvim_get_current_buf() })
			end, { desc = "Format buffer" })
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
		opts = {
			indent = {
				animate = { enabled = false },
				indent = { enabled = false },
				scope = { enabled = true },
			},
			gitbrowse = {},
			scratch = {
				ft = "text",
				win_by_ft = { lua = false },
				filekey = {
					branch = false,
				},
				win = {
					position = "current",
					fixbuf = false,
					footer_keys = false,
					keys = { q = false },
					on_buf = function(self)
						vim.bo[self.buf].filetype = "text"
						vim.bo[self.buf].syntax = ""
					end,
				},
			},
		},
		config = function(_, opts)
			local snacks = require("snacks")
			if not snacks.did_setup then
				snacks.setup(opts)
			end
			local function open_scratch(opts)
				local scratch = snacks.scratch.get(opts)
				local buf = vim.fn.bufnr(scratch.file)
				local win = buf ~= -1 and vim.fn.bufwinid(buf) or -1
				if win ~= -1 then
					vim.api.nvim_set_current_win(win)
					return
				end
				snacks.scratch.open(opts)
			end

			local function daily_scratch()
				local today = os.date("%Y-%m-%d")
				open_scratch({
					name = "Daily Scratch " .. today,
					ft = "text",
					template = today .. "\n\n",
					filekey = {
						cwd = false,
						branch = false,
						count = false,
					},
				})
			end

			local last_scratch_delete_target_count = 0
			local function select_scratch()
				local fzf = require("fzf-lua")
				local scratches = snacks.scratch.list()
				local graveyard = vim.fn.stdpath("data") .. "/scratch-graveyard"
				local function file_from_entry(entry)
					return entry and entry:match("\t([^\t]+)$")
				end
				local function first_nonempty_line(file)
					local ok, lines = pcall(vim.fn.readfile, file, "", 20)
					if not ok then
						return nil
					end
					for _, line in ipairs(lines) do
						line = vim.trim(line):gsub("\t", " ")
						if line ~= "" then
							return line:sub(1, 80)
						end
					end
				end
				local function open_selected(selected, win)
					local file = file_from_entry(selected[1])
					if file then
						open_scratch({ file = file, win = win })
					end
				end
				local function new_scratch()
					open_scratch({
						name = "Scratch " .. os.date("%Y-%m-%d %H:%M:%S") .. "." .. vim.uv.hrtime(),
						ft = "text",
						filekey = {
							branch = false,
						},
					})
				end
				local function undo_deleted_scratch()
					if vim.fn.executable("rip") ~= 1 then
						vim.notify("rip not found; nothing was restored", vim.log.levels.ERROR)
						return
					end
					if last_scratch_delete_target_count == 0 then
						vim.notify("No scratch deletion to undo", vim.log.levels.WARN)
						return
					end

					for _ = 1, last_scratch_delete_target_count do
						local output = vim.fn.system({ "rip", "--graveyard", graveyard, "-u" })
						if vim.v.shell_error ~= 0 then
							vim.notify(output, vim.log.levels.ERROR)
							return
						end
					end
					last_scratch_delete_target_count = 0
					vim.notify("Restored last scratch deletion")
					vim.schedule(select_scratch)
				end
				local entries = {}
				for _, item in ipairs(scratches) do
					local cwd = item.cwd and vim.fn.fnamemodify(item.cwd, ":~") or ""
					local project = cwd ~= "" and vim.fn.fnamemodify(cwd, ":t") or "global"
					local count = item.count and item.count > 1 and (" #" .. item.count) or ""
					local title = first_nonempty_line(item.file) or ((item.name or "Scratch") .. count)
					local display = string.format("%-20s %-12s %s", project, "text", title)
					entries[#entries + 1] = display .. "\t" .. item.file
				end

				fzf.fzf_exec(entries, {
					prompt = "Scratch> ",
					header = "enter open | alt-n new | ctrl-v vsplit | ctrl-s split | ctrl-x del | alt-u undo",
					preview = "bat --style=numbers --color=always --language=txt {2} 2>/dev/null || cat {2}",
					fzf_opts = {
						["--delimiter"] = "\t",
						["--with-nth"] = "1",
						["--preview-window"] = "down,50%,border-top",
					},
					actions = {
						["enter"] = function(selected)
							open_selected(selected)
						end,
						["ctrl-v"] = function(selected)
							open_selected(selected, { position = "right", width = 0.5 })
						end,
						["ctrl-s"] = function(selected)
							open_selected(selected, { position = "bottom", height = 0.4 })
						end,
						["alt-n"] = new_scratch,
						["alt-u"] = undo_deleted_scratch,
						["ctrl-x"] = function(selected)
							if vim.fn.executable("rip") ~= 1 then
								vim.notify("rip not found; scratch was not deleted", vim.log.levels.ERROR)
								return
							end

							local targets = {}
							local scratch_count = 0
							for _, entry in ipairs(selected) do
								local file = file_from_entry(entry)
								if file then
									scratch_count = scratch_count + 1
									local buf = vim.fn.bufnr(file)
									if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
										vim.api.nvim_buf_call(buf, function()
											vim.cmd("silent! write")
										end)
										pcall(vim.api.nvim_buf_delete, buf, { force = true })
									end
									targets[#targets + 1] = file
									if vim.uv.fs_stat(file .. ".meta") then
										targets[#targets + 1] = file .. ".meta"
									end
								end
							end
							if #targets == 0 then
								return
							end

							local args = { "rip", "--graveyard", graveyard }
							vim.list_extend(args, targets)
							local output = vim.fn.system(args)
							if vim.v.shell_error ~= 0 then
								vim.notify(output, vim.log.levels.ERROR)
								return
							end
							last_scratch_delete_target_count = #targets
							vim.notify(
								("Deleted %d scratch buffer%s with rip"):format(
									scratch_count,
									scratch_count == 1 and "" or "s"
								)
							)
							vim.schedule(select_scratch)
						end,
					},
				})
			end

			vim.keymap.set("n", "<leader>.", function()
				open_scratch({})
			end, { desc = "Open scratch buffer" })
			vim.keymap.set("n", "<leader>s", select_scratch, { desc = "Select scratch buffer" })
			vim.keymap.set("n", "<leader>S", daily_scratch, { desc = "Daily scratch buffer" })
			vim.keymap.set("n", "<leader>gb", function()
				snacks.gitbrowse()
			end, { desc = "Git browse" })
			vim.keymap.set("n", "<leader>gB", function()
				snacks.gitbrowse({
					open = function(url)
						vim.fn.setreg("+", url)
						vim.notify("Copied: " .. url)
					end,
				})
			end, { desc = "Copy git browse URL" })
		end,
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
