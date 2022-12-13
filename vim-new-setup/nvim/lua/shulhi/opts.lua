local opt = vim.opt

-- line numbers
opt.number = true
opt.signcolumn = "yes"
opt.colorcolumn = "120"

-- tabs & indentations
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = 2
opt.tabstop = 2

-- line wrap
opt.wrap = false

opt.hidden = true

-- clipboard
opt.clipboard:append("unnamed")
opt.cursorline = true
opt.hlsearch = true
opt.showmatch = true
opt.showcmd = true
opt.scrolloff = 10
opt.laststatus = 2
opt.ttimeoutlen = 50
opt.encoding = "utf-8"
opt.mouse = "a"
opt.backspace = "indent,eol,start"
opt.foldmethod = "syntax"

opt.list = true
opt.listchars = {
  tab = '·→',
  extends = '⟩',
  precedes = '⟨',
  trail = '·'
}

opt.updatetime = 200
opt.autoread = true

-- status line
-- set statusline+=%#warningmsg#
-- set statusline+=%*


vim.g.mapleader = " "

vim.g.ormolu_options = { "--stdin-input-file . " }

vim.g.airline_powerline_fonts = 1

vim.api.nvim_set_keymap("n", ";", ":", { noremap = true })

vim.api.nvim_set_keymap("n", "<c-c>", "<esc>", {})
vim.api.nvim_set_keymap("i", "<c-c>", "<esc>", {})
vim.api.nvim_set_keymap("v", "<c-c>", "<esc>", {})
vim.api.nvim_set_keymap("o", "<c-c>", "<esc>", {})

vim.api.nvim_set_keymap("c", "w!!", "!sudo tee > /dev/null %", {})

vim.api.nvim_set_keymap("n", "<leader>h", ":wincmd h<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>j", ":wincmd j<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>k", ":wincmd k<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>l", ":wincmd l<CR>", { noremap = true })
