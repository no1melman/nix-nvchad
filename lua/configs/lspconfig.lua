local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local util = require "lspconfig/util"

local servers = {
  "yamlls",
  "lemminx",
  "ts_ls",
  "gopls",
  "rust_analyzer",
  "svelte",
  "html",
  "cssls",
  "dockerls",
  "terraformls",
  "nixd",
  "pyright",
  "zls",
  "rzls",
}

-- lsps with default config
for _, lsp in ipairs(servers) do
  vim.lsp.enable(lsp)
end

vim.lsp.config("gopls", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
})

local osName = vim.loop.os_uname().sysname

if osName == "Linux" then
  local bicepDllLocation = os.getenv "BICEP_DLL_LOCATION"
  vim.lsp.config("bicep", {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "dotnet", bicepDllLocation },
  })
else
  vim.lsp.config("bicep", {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "dotnet", "C:/tools/bicep/Bicep.LangServer.dll" },
  })
end
vim.lsp.enable "bicep"

require("ionide").setup {
  on_init = on_init,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    vim.lsp.codelens.refresh()
  end,
  capabilities = capabilities,
}

if osName == "Linux" then
  local powershellEs = os.getenv "POWERSHELL_ES"
  vim.lsp.config("powershell_es", {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    bundle_path = powershellEs,
  })
else
  vim.lsp.config("powershell_es", {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
  })
end
vim.lsp.enable "powershell_es"

if osName == "Linux" then
  local roslynLs = os.getenv "ROSLYN_LSP"
  vim.lsp.config("roslyn", {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {
      "dotnet",
      roslynLs .. "/lib/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll",
      "--logLevel=Information",
      "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
      "--stdio",
    },
    handlers = require "rzls.roslyn_handlers",
    settings = {
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
      },
    },
  })
else
  vim.lsp.config("roslyn", {
    handlers = require "rzls.roslyn_handlers",
    settings = {
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
      },
    },
  })
end
vim.lsp.enable "roslyn"

if osName == "Linux" then
  vim.lsp.config("clangd", {
    cmd = { "clangd" },
  })
else
  vim.lsp.config("clangd", {
    cmd = { "clangd", "--query-driver=C:/ProgramData/chocolatey/lib/winlibs/tools/mingw64/bin/g++.exe" },
  })
end
vim.lsp.enable "clangd"
