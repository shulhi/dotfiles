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
