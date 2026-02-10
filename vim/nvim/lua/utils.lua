local function trim(s)
  return s:match '^()%s*$' and '' or s:match '^%s*(.*%S)'
end

local M = {}

M.themepath = os.getenv("HOME") .. "/.dotfiles/active-theme/theme"

function M.adjust_theme()
  vim.schedule(function()
    local f = io.open(M.themepath, "r")
    if not f then
      vim.notify("Failed to open theme file: " .. M.themepath, vim.log.levels.WARN)
      return
    end

    local data = f:read("*all")
    f:close()

    local theme = trim(data)

    if theme == 'light' then
      vim.o.background = 'light'
      vim.cmd("colorscheme catppuccin")
    else
      vim.g.gruvbox_contrast_dark = "hard"
      vim.g.gruvbox_invert_selection = true
      vim.o.background = 'dark'
      vim.cmd("colorscheme gruvbox")
    end
  end)
end

return M
