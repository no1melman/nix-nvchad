-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@class CustomChadrc
local M = {}

M.ui = {
  theme = "catppuccin",

  tabufline = {
    --  more opts
    order = { "buffers", "tabs", "btns" },
  },
}


-- Define custom key mappings
M.mappings = {
  general = {
    -- Map Alt+i to toggle the floating terminal in normal and terminal modes
    ["<A-i>"] = {
      function()
        require("nvchad.term").toggle {
          pos = "float",
          id = "floatTerm",
          float_opts = {
            row = 0.35,
            col = 0.05,
            width = 0.9,
            height = 0.8,
          },
        }
      end,
      "Toggle floating terminal",
      mode = { "n", "t" },
    },
  },
}

return M
