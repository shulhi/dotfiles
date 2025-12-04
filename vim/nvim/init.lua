utils = require("utils")

local opt = vim.opt

opt.termguicolors = true

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

opt.clipboard = "unnamedplus"

vim.g.mapleader = " "

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

vim.cmd[[
au TabLeave * let g:lasttab = tabpagenr()
]]

vim.cmd[[
au BufRead,BufNewFile *.res set filetype=rescript
au BufRead,BufNewFile *.resi set filetype=rescript
]]

vim.api.nvim_set_keymap("n", "<C-l>", ':exe "tabn ".g:lasttab<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-l>", ':exe "tabn ".g:lasttab<CR>', { noremap = true, silent = true })

-- Lazy vim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- local fse = vim.loop.new_fs_event()
-- vim.loop.fs_event_start(fse, utils.themepath, {}, function(err, fname, status)
--   if (err) then
--     print("Error " .. err)
--   else
--     utils.adjust_theme()
--   end
-- end)


vim.api.nvim_create_autocmd({"VimEnter"}, {
  callback = function()
    utils.adjust_theme()
  end
})

-- Enable terminal background change reporting (DECSET 2031)
vim.opt.termguicolors = true

-- Setup auto-command for background change
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = function()
    if vim.o.background == "dark" then
      vim.cmd("colorscheme gruvbox")  -- your dark theme
    else
      vim.defer_fn(function()
        vim.cmd("colorscheme catppuccin")  -- your light theme
      end, 10)
    end
  end,
})

require("lazy").setup("plugins")
require("lsp")
