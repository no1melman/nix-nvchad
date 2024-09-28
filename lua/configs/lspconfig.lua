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

lspconfig.bicep.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "dotnet", "C:/tools/bicep/Bicep.LangServer.dll" },
}

require("ionide").setup {
  on_init = on_init,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    vim.lsp.codelens.refresh()
  end,
  capabilities = capabilities,
}

lspconfig.powershell_es.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
}

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

lspconfig.clangd.setup {
  cmd = { "clangd", "--query-driver=C:/ProgramData/chocolatey/lib/winlibs/tools/mingw64/bin/g++.exe" },
}
