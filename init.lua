vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

require("lazy").setup({ { import = "plugins" } })

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.keymap.set("n", "<leader>tt", "<cmd>botright 15new | term<cr>i")

vim.o.clipboard = "unnamedplus"

vim.o.laststatus = 3

local file_info = "%#StatusLineFile#  %f "
vim.opt.statusline = file_info

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineFile", { fg = "#c0caf5", bg = "NONE" })
