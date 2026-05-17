# nix-nvchad

Personal Neovim config: an NvChad v2.5 distro adapted for a Nix environment (also runs on Windows).

## Layout

- `init.lua` — bootstraps lazy.nvim, loads NvChad, theme, options, mappings. OS-specific Wayland clipboard on Linux.
- `lua/chadrc.lua` — NvChad theme + UI overrides.
- `lua/options.lua` — vim opts (PowerShell as `:shell`), Ionide globals, `*.bicep` filetype autocmd.
- `lua/mappings.lua` — `jj`→`<ESC>`, completion trigger, DAP keys, floating terminal.
- `lua/plugins/init.lua` — plugin specs: treesitter list, conform, nvim-tree, lspconfig, DAP (+ go, ui), Mason, Ionide (F#), roslyn.nvim (C# + razor via rzls).
- `lua/configs/lspconfig.lua` — LSP servers; OS-branched paths for `bicep`, `powershell_es`, `clangd`. Roslyn block currently commented out.
- `lua/configs/mason.lua` — Mason registries (incl. Crashdummyy for roslyn/rzls) + ensure_installed.
- `lua/configs/conform.lua` — formatters per filetype, format-on-save.

## Conventions

- Uses NvChad v2.5 API (`vim.lsp.config` / `vim.lsp.enable`, not the old `lspconfig[server].setup`).
- Cross-platform: gate behavior on `vim.loop.os_uname().sysname == "Linux"`; Windows paths hard-coded as the else branch.
- Env vars used for tool paths on Linux: `BICEP_DLL_LOCATION`, `POWERSHELL_ES`, (formerly `ROSLYN_LSP`). Set these in the Nix shell/home-manager that wraps this config.
- Formatter: stylua (`.stylua.toml` at root).
