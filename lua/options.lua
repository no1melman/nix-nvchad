require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

vim.opt.shell = "pwsh"
vim.opt.shellcmdflag =
  "-NoLogo -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

vim.opt.scrolloff = 8

-- Ionide variables
vim.g["fsharp#show_signature_on_cursor_move"] = 0
vim.g["fsharp#lsp_auto_setup"] = 0
vim.g["fsharp#workspace_mode_peek_deep_level"] = 4

vim.api.nvim_create_user_command("FSharpRefreshCodeLens", function()
  vim.lsp.codelens.refresh()
  print "[FSAC] Refreshing CodeLens"
end, {
  bang = true,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.bicep",
  command = "set filetype=bicep",
})
