-- Required. This spec's `config` replaces NvChad's own, so nothing else calls defaults().
-- It applies capabilities + on_init to every server via vim.lsp.config("*", ...), registers
-- the LSP keymaps on LspAttach, loads the diagnostic/base46 config, and enables lua_ls.
require("nvchad.configs.lspconfig").defaults()

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
  "pylsp",
}

-- lsps with default config; capabilities/on_init/on_attach all come from defaults() above
vim.lsp.enable(servers)

vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath "config"
        and (vim.uv.fs_stat(path .. "/.luarc") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

vim.lsp.config("gopls", {
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

local osName = vim.uv.os_uname().sysname

if osName == "Linux" then
  local bicepDllLocation = os.getenv "BICEP_DLL_LOCATION"
  vim.lsp.config("bicep", {
    cmd = { "dotnet", bicepDllLocation },
  })
else
  vim.lsp.config("bicep", {
    cmd = { "dotnet", "C:/tools/bicep/Bicep.LangServer.dll" },
  })
end
vim.lsp.enable "bicep"

-- F#/Ionide is configured in its own lazy spec (lua/plugins/init.lua) so that it
-- honours `ft` and cannot take the rest of this file down if it fails to load.

if osName == "Linux" then
  local powershellEs = os.getenv "POWERSHELL_ES"
  vim.lsp.config("powershell_es", {
    bundle_path = powershellEs,
  })
else
  vim.lsp.config("powershell_es", {
    bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
  })
end
vim.lsp.enable "powershell_es"

-- if osName == "Linux" then
--   local roslynLs = os.getenv "ROSLYN_LSP"
--   vim.lsp.config("roslyn", {
--     on_init = on_init,
--     on_attach = on_attach,
--     capabilities = capabilities,
--     cmd = {
--       "dotnet",
--       roslynLs .. "/lib/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll",
--       "--logLevel=Information",
--       "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
--       "--stdio",
--     },
--     handlers = require "rzls.roslyn_handlers",
--     settings = {
--       ["csharp|code_lens"] = {
--         dotnet_enable_references_code_lens = true,
--       },
--     },
--   })
-- else
--   vim.lsp.config("roslyn", {
--     handlers = require "rzls.roslyn_handlers",
--     settings = {
--       ["csharp|code_lens"] = {
--         dotnet_enable_references_code_lens = true,
--       },
--     },
--   })
-- end
-- vim.lsp.enable "roslyn"

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
