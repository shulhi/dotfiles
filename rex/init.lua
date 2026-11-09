rex.bind("cmd+r", "client.mode.enter", { name = "resize" })

rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/down", "pane.resize", { direction = "down" })

-- amount is a percentage of the split; the default is 5
rex.bind("resize/shift+left", "pane.resize", { direction = "left", amount = 15 })
rex.bind("resize/shift+right", "pane.resize", { direction = "right", amount = 15 })
rex.bind("resize/shift+up", "pane.resize", { direction = "up", amount = 15 })
rex.bind("resize/shift+down", "pane.resize", { direction = "down", amount = 15 })

-- Paste a clipboard image through Portside into the focused Rex terminal.
local portside_checkout = "/Users/shulhi/Dev/portside"
dofile(portside_checkout .. "/integrations/rex/image-paste.lua").setup {
  helper = portside_checkout .. "/client/dist/Portside.app/Contents/Helpers/portside-paste",
  rex_cli = "/Users/shulhi/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex",
  hosts = { ["shulhi-x13"] = {host = "100.123.29.98", port = 9417, folder = "rex-images"} },
}
rex.bind("cmd+shift+v", "portside_image_paste")
