-- Rex's native Mac client can render its OS appearance while the canonical
-- terminal still retains the previous remote client's palette. Resolve the
-- current owner before choosing the source of appearance on macOS.
local M = {}
function M.new(apply_colorscheme)
  local generation = 0
  local function query_terminal()
    vim.api.nvim_ui_send("\027]11;?\007")
  end
  local function macos(token)
    vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }, function(res)
      vim.schedule(function()
        if generation ~= token then return end
        vim.o.background = res.code == 0 and res.stdout:match("Dark") and "dark" or "light"
        apply_colorscheme()
      end)
    end)
  end
  local script = [[
    local view = rex.call("session.view", {session_id=rex.args.session})
    local owner
    for _, window in ipairs(view.windows or {}) do
      for _, layer in ipairs(window.layers or {}) do
        for _, block in ipairs(layer.blocks or {}) do
          if block.block_id == rex.args.block then owner = block.owner end
        end
      end
    end
    for _, client in ipairs(rex.call("client.list", {kinds={"app"}}).clients or {}) do
      if client.client_id == owner then return client.info end
    end
    return {}
  ]]
  return function()
    generation = generation + 1
    local token = generation
    if vim.uv.os_uname().sysname ~= "Darwin" or not vim.env.REX_SESSION or not vim.env.REX_BLOCK
      or vim.fn.executable("rex") == 0 then
      query_terminal()
      return
    end
    local command = { "rex", "--autostart=false", "--timeout", "2s", "do", "-e", script,
      "--args", vim.json.encode({session=vim.env.REX_SESSION, block=vim.env.REX_BLOCK}), "--json" }
    if vim.env.REX_SERVER and vim.env.REX_SERVER ~= "" then
      table.insert(command, 2, "--server=" .. vim.env.REX_SERVER)
    end
    vim.system(command, { text = true }, function(res)
      vim.schedule(function()
        if generation ~= token then return end
        local ok, info = pcall(vim.json.decode, res.stdout or "")
        if res.code == 0 and ok and type(info) == "table" and info.platform == "macos"
          and (info.name == "Rex" or info.name == "Rex Beta") then
          macos(token)
        else
          query_terminal()
        end
      end)
    end)
  end
end
return M
