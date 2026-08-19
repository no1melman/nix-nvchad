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
- `lua/configs/ts-compat.lua` — treesitter predicate/directive shim for Neovim 0.12 (see Version constraints).
- `scripts/` — headless helpers: `check.sh` (smoke test), `lazy.sh` (lockfile/plugin management).

## Conventions

- Uses NvChad v2.5 API (`vim.lsp.config` / `vim.lsp.enable`, not the old `lspconfig[server].setup`).
- Cross-platform: gate behavior on `vim.loop.os_uname().sysname == "Linux"`; Windows paths hard-coded as the else branch.
- Env vars used for tool paths on Linux: `BICEP_DLL_LOCATION`, `POWERSHELL_ES`, (formerly `ROSLYN_LSP`). Set these in the Nix shell/home-manager that wraps this config.
- Formatter: stylua (`.stylua.toml` at root).

## Deployment

This repo is not edited in place on the target machine. The loop is: commit and push here →
`nix flake update` on the machine → nix pulls the new commit and deploys it to `~/.config/nvim`.
So `~/.config/nvim` is a *generated copy*: never edit it, and never let a test write to it —
changes there are lost on the next update and, worse, mask whether the repo itself is correct.

## Testing

Test headlessly, with this repo as the config, and without touching the deployed copy:

- `./scripts/check.sh [file...]` — starts nvim with this repo as its config, opens a sample
  file per filetype and forces a synchronous treesitter parse (injections included). Exits
  non-zero on any error. Add cases here when a filetype breaks.
- `./scripts/lazy.sh [sync|update|restore]` — runs lazy.nvim against this repo so
  `lazy-lock.json` is written back here. `-i` isolates plugins in a temp dir too.

Both work the same way: a temp `XDG_CONFIG_HOME` containing a symlink named `nvim` pointing
at this repo (nvim derives its config dir from `$XDG_CONFIG_HOME/$NVIM_APPNAME`, so the link
has to be named `nvim`). Nothing under `~/.config` is read or written. Plugins and parsers in
`~/.local/share/nvim` are shared by default, which is deliberate — that is the code that
actually runs on the machine — but it means `lazy.sh sync/update` does move them. Use `-i`
when that matters.

For anything ad hoc, follow the same shape: `nvim --headless -l script.lua` under a temp
`XDG_CONFIG_HOME`. `nvim -l` still sources the config, so plugins load as in a real session.

## Version constraints

- Neovim 0.12.x, nvim-treesitter is pinned to `master`, which is **archived and supports
  0.10/0.11 only**. `lua/configs/ts-compat.lua` bridges the gap (0.12 dropped the `all`
  option on treesitter predicates/directives, which every nvim-treesitter directive relies
  on). Delete it if/when NvChad and this config move to nvim-treesitter's `main` branch.
