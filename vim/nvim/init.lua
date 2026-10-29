local utils = require("utils")

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

opt.cursorline = true
opt.hlsearch = true
opt.showmatch = true
opt.showcmd = true
opt.scrolloff = 10
opt.laststatus = 2
opt.ttimeoutlen = 50
opt.mouse = "a"
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
if not vim.uv.fs_stat(lazypath) then
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

local function set_colorscheme_from_background()
  if vim.o.background == "dark" then
    vim.g.gruvbox_contrast_dark = "hard"
    vim.g.gruvbox_invert_selection = true
    vim.cmd("colorscheme gruvbox")
  else
    vim.cmd("colorscheme catppuccin")
  end
end

local sysname = vim.uv.os_uname().sysname
local in_rex = os.getenv("REX_SESSION") ~= nil or (os.getenv("TERM") or ""):match("rex") ~= nil

if sysname == "Linux" and in_rex then
  -- Rex (no tmux): follow the terminal's own theme. Nvim queries the
  -- terminal background with OSC 11 at startup (and on theme-change
  -- notifications if the terminal supports mode 2031), setting
  -- 'background' accordingly. Re-query on FocusGained as a fallback in
  -- case the theme changed while we weren't listening.
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = set_colorscheme_from_background,
  })

  vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
      vim.api.nvim_ui_send("\027]11;?\007")
    end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "background",
    callback = set_colorscheme_from_background,
  })
elseif sysname == "Linux" then
  -- Other Linux: watch the theme file for changes
  local fse = vim.uv.new_fs_event()
  local theme_dir = vim.fn.fnamemodify(utils.themepath, ":h")
  vim.uv.fs_event_start(fse, theme_dir, {}, function(err, fname, status)
    if err then
      vim.notify("Error watching theme: " .. err, vim.log.levels.ERROR)
    else
      vim.schedule(function()
        utils.adjust_theme()
      end)
    end
  end)
  vim.api.nvim_create_autocmd({"VimEnter"}, {
    callback = function()
      utils.adjust_theme()
    end
  })
end


-- On macOS, handle theme changes via background option
if sysname == "Darwin" then
  -- tmux `focus-events on` makes switching tmux windows fire
  -- FocusGained even without real terminal-level focus change, but
  -- the OSC 11 auto-detection push it would otherwise rely on only
  -- ever reaches whichever tmux window was on screen at the moment
  -- macOS actually changed appearance. So on FocusGained, actively
  -- ask macOS for the current appearance instead of trusting
  -- whatever 'background' was left at.
  local function sync_macos_theme()
    vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }, function(res)
      vim.schedule(function()
        local is_dark = res.code == 0 and res.stdout:match("Dark") ~= nil
        vim.o.background = is_dark and "dark" or "light"
        set_colorscheme_from_background()
      end)
    end)
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    callback = sync_macos_theme,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "background",
    callback = set_colorscheme_from_background,
  })
end

require("lazy").setup("plugins")
require("lsp")
