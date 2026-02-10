local uv = vim.uv

function trim6(s)
  return s:match '^()%s*$' and '' or s:match '^%s*(.*%S)'
end

-- taken from https://github.com/nvim-lua/plenary.nvim
local read_file = function(path, callback)
  uv.fs_open(path, "r", 438, function(err, fd)
    assert(not err, err)
    uv.fs_fstat(fd, function(err, stat)
      assert(not err, err)
      uv.fs_read(fd, stat.size, 0, function(err, data)
        assert(not err, err)
        uv.fs_close(fd, function(err)
          assert(not err, err)
          callback(data)
        end)
      end)
    end)
  end)
end

local M = {}

M.themepath = os.getenv("HOME") .. "/.theme"

function M.adjust_theme()
  local themepath = M.themepath
  read_file(themepath, vim.schedule_wrap(function(data)
    if trim6(data) == 'light' then
      -- vim.opt.background = 'light'
      vim.cmd("colorscheme catppuccin")
    else
      --.opt.background = 'dark'
      vim.g.gruvbox_contrast_dark = "hard"
      vim.g.gruvbox_invert_selection = true
      vim.cmd("colorscheme gruvbox")
    end
  end))
end

return M
