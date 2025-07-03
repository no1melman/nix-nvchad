vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

local osName = vim.loop.os_uname().sysname
if osName == "Linux" then
  vim.g.clipboard = {
    name = "wl clipboard",
    copy = {
      ["+"] = "wl-copy --foreground --type text/plain",
      ["*"] = "wl-copy --foreground --type text/plain --primary",
    },
    paste = {
      ["+"] = "wl-paste --no-newline",
      ["*"] = "wl-paste --no-newline --primary",
    },
    cache_enabled = true,
  }
end

local function command_exists(cmd)
  local handle = io.popen("which " .. cmd .. " 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

vim.api.nvim_create_user_command('MarkdownPreview', function()
  -- Check if required commands exist
  if not command_exists("pandoc") then
    vim.notify("pandoc is not installed. Please install pandoc to use MarkdownPreview.", vim.log.levels.ERROR)
    return
  end
  
  if not command_exists("entr") then
    vim.notify("entr is not installed. Please install entr to use MarkdownPreview.", vim.log.levels.ERROR)
    return
  end

  local filename = vim.fn.expand('%:p')
  local output = '/tmp/nvim_markdown_preview.html'
  
  -- Kill existing entr processes
  vim.fn.system('pkill -f "entr.*pandoc"')
  
  -- Start new watcher
  local cmd = string.format('echo "%s" | entr pandoc "%s" -s -o "%s" &', filename, filename, output)
  vim.fn.system(cmd)
  
  -- Open in browser (check which browser command exists)
  local browser_cmd = "xdg-open"  -- Default for Linux
  if command_exists("open") then
    browser_cmd = "open"  -- macOS
  elseif command_exists("start") then
    browser_cmd = "start"  -- Windows
  end
  
  vim.fn.system(string.format('%s "%s"', browser_cmd, output))
  vim.notify("MarkdownPreview started. File will auto-update on save.", vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command('MarkdownPreviewStop', function()
  vim.fn.system('pkill -f "entr.*pandoc"')
  vim.notify("MarkdownPreview stopped.", vim.log.levels.INFO)
end, {})
