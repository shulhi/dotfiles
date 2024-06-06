return {
  "m4xshen/autoclose.nvim",
  event = "BufRead",
  config = function() 
    require("autoclose").setup()
  end
}
