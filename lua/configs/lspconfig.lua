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

-- Linux and macOS both get their tools from nix (paths via env vars); Windows is hard-coded.
local isWindows = vim.fn.has "win32" == 1

if not isWindows then
  local bicepDllLocation = os.getenv "BICEP_DLL_LOCATION"
  -- Not every machine's nix config provides bicep; without the dll the server can't start.
  if bicepDllLocation then
    vim.lsp.config("bicep", {
      cmd = { "dotnet", bicepDllLocation },
    })
    vim.lsp.enable "bicep"
  end
else
  vim.lsp.config("bicep", {
    cmd = { "dotnet", "C:/tools/bicep/Bicep.LangServer.dll" },
  })
  vim.lsp.enable "bicep"
end

-- F#/Ionide is configured in its own lazy spec (lua/plugins/init.lua) so that it
-- honours `ft` and cannot take the rest of this file down if it fails to load.

if not isWindows then
  local powershellEs = os.getenv "POWERSHELL_ES"
  -- lspconfig's default cmd passes `-LogLevel Information`, which the nixpkgs
  -- PSES (4.3.x) rejects; it only accepts Diagnostic/Verbose/Normal/Warning/Error.
  local logDir = vim.fs.dirname(vim.lsp.log.get_filename())
  vim.lsp.config("powershell_es", {
    bundle_path = powershellEs,
    cmd = {
      "pwsh",
      "-NoLogo",
      "-NoProfile",
      "-Command",
      ("& '%s/PowerShellEditorServices/Start-EditorServices.ps1'"):format(powershellEs)
        .. (" -LogPath '%s/powershell_es.log'"):format(logDir)
        .. (" -SessionDetailsPath '%s/powershell_es.session.json'"):format(logDir)
        .. " -FeatureFlags @() -AdditionalModules @() -HostName nvim -HostProfileId 0"
        .. " -HostVersion 1.0.0 -Stdio -LogLevel Normal",
    },
  })
else
  vim.lsp.config("powershell_es", {
    bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
  })
end
vim.lsp.enable "powershell_es"

-- if not isWindows then
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

if isWindows then
  vim.lsp.config("clangd", {
    cmd = { "clangd", "--query-driver=C:/ProgramData/chocolatey/lib/winlibs/tools/mingw64/bin/g++.exe" },
  })
end
-- Elsewhere the default `clangd` from PATH is right: nix's on Linux, Xcode's (which knows
-- the Apple SDKs and frameworks) on macOS.
vim.lsp.enable "clangd"

-- Swift. sourcekit-lsp also claims c/cpp/objc/objcpp by default; leave those to clangd so
-- the two don't both attach. Xcode projects (no Package.swift) need a buildServer.json,
-- e.g. from `xcode-build-server config -project X.xcodeproj -scheme X`.
vim.lsp.config("sourcekit", {
  filetypes = { "swift" },
})
vim.lsp.enable "sourcekit"
