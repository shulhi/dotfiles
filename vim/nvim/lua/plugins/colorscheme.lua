return {
  { "catppuccin/nvim", name = "catppuccin", 
    lazy = false,
    priority = 1000 
  },
  {
    "savq/melange-nvim"
  },
  {
    "gruvbox-community/gruvbox",
    lazy = false,
    priority = 1000,
    config = function() 
      vim.opt.termguicolors = true
      local uv = vim.loop

      -- trim function, taken from http://lua-users.org/wiki/StringTrim
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

      -- CHANGE THIS TO THE FILEPATH YOU'RE USING
      local themepath = "/home/shulhi/.theme"

      function adjust_theme()
        read_file(themepath, vim.schedule_wrap(function(data)
          if trim6(data) == 'light' then
            vim.opt.background = 'light'
            vim.cmd("colorscheme catppuccin")
          else
            vim.opt.background = 'dark'
            vim.g.gruvbox_contrast_dark = "hard"
            vim.g.gruvbox_invert_selection = true
            vim.cmd("colorscheme gruvbox")
          end
        end))
      end

      local fse = vim.loop.new_fs_event()
      vim.loop.fs_event_start(fse, themepath, {}, function(err, fname, status)
        if (err) then
          print("Error " .. err)
        else
          adjust_theme()
        end
      end)

      vim.defer_fn(function(data)
        adjust_theme()
      end, 800)
    end
  }
}
