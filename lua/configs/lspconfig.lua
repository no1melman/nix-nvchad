local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local util = require "lspconfig/util"

local lspconfig = require "lspconfig"
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
}

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

lspconfig.gopls.setup {
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
}

local osName = vim.loop.os_uname().sysname

if osName == "Linux" then
  local bicepDllLocation = os.getenv "BICEP_DLL_LOCATION"
  lspconfig.bicep.setup {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "dotnet", bicepDllLocation },
  }
else
  lspconfig.bicep.setup {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "dotnet", "C:/tools/bicep/Bicep.LangServer.dll" },
  }
end

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
  lspconfig.powershell_es.setup {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    bundle_path = powershellEs,
  }
else
  lspconfig.powershell_es.setup {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
  }
end

if osName == "Linux" then
  local omnisharp = os.getenv "OMNISHARP_LOCATION"
  lspconfig.omnisharp.setup {

    cmd = { "dotnet", omnisharp },
    on_attach = on_attach,
    capabilities = capabilities,

    enable_roslyn_analyzers = true,
    enable_import_completion = true,
    enable_package_restore = true,
    enable_editorconfig_support = true,

    analyze_open_documents_only = false,

    handlers = {
      ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
  }
else
  lspconfig.omnisharp.setup {
    cmd = { "dotnet", vim.fn.stdpath "data" .. "/mason/packages/omnisharp/libexec/OmniSharp.dll" },
    on_attach = on_attach,
    capabilities = capabilities,

    enable_roslyn_analyzers = true,
    enable_import_completion = true,
    enable_package_restore = true,
    enable_editorconfig_support = true,

    analyze_open_documents_only = false,

    handlers = {
      ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
  }
end

if osName == "Linux" then
  lspconfig.clangd.setup {
    cmd = { "clangd" },
  }
else
  lspconfig.clangd.setup {
    cmd = { "clangd", "--query-driver=C:/ProgramData/chocolatey/lib/winlibs/tools/mingw64/bin/g++.exe" },
  }
end
