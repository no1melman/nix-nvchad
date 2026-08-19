#!/usr/bin/env bash
# Headless smoke test: start nvim with *this repo* as the config, open a sample file per
# filetype we care about, and force a full treesitter parse (injections included) to see
# whether anything errors.
#
#   ./scripts/check.sh                 # run the built-in sample files
#   ./scripts/check.sh path/to/file    # ...plus/instead your own files
#
# Read-only with respect to your editor: the config dir is a throwaway temp dir holding a
# symlink to this repo, so ~/.config/nvim (the copy nix deploys) is never touched. Plugins
# and parsers are shared with your real install (~/.local/share/nvim) -- opening buffers
# does not modify them, and sharing is what makes this test the same code you actually run.
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
# nvim derives its config dir from $XDG_CONFIG_HOME/$NVIM_APPNAME, so the link has to be
# named "nvim" (same trick as scripts/lazy.sh).
ln -s "$repo" "$tmp/nvim"
mkdir -p "$tmp/files"

if [[ $# -gt 0 ]]; then
  files=("$@")
else
  # One sample per filetype whose queries have bitten us. Markdown/bash/hcl/html all drive
  # injection directives, which is where nvim-treesitter master vs Neovim 0.12 breaks.
  cat >"$tmp/files/sample.md" <<'MD'
# Title

```lua
local x = 1
```

```bash
echo hi
```

<div>html block</div>
MD
  cat >"$tmp/files/sample.sh" <<'SH'
#!/usr/bin/env bash
echo "hello $HOME"
SH
  cat >"$tmp/files/sample.tf" <<'TF'
resource "null_resource" "x" {
  provisioner "local-exec" {
    command = "echo hi"
  }
}
TF
  cat >"$tmp/files/sample.lua" <<'LUA'
local M = {}
function M.go()
  return vim.fn.has "nvim-0.12"
end
return M
LUA
  files=("$tmp"/files/sample.*)
fi

cat >"$tmp/probe.lua" <<'LUA'
-- `nvim -l` still sources the config, so plugins are loaded exactly as in a real session.
local failed = false

for _, f in ipairs(_G.arg) do
  vim.cmd.edit(vim.fn.fnameescape(f))
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local injected = {}

  local ok, err = pcall(function()
    local parser = vim.treesitter.get_parser(buf, nil, { error = false })
    if not parser then
      return
    end
    -- Async parsing would swallow the error into a redraw; force it onto this stack.
    vim.g._ts_force_sync_parsing = true
    parser:parse(true)
    for lang in pairs(parser:children()) do
      injected[#injected + 1] = lang
    end
  end)

  table.sort(injected)
  local detail = #injected > 0 and (" (injects: " .. table.concat(injected, ", ") .. ")") or ""
  if ok then
    io.stderr:write(string.format("ok    %-14s %-11s%s\n", vim.fn.fnamemodify(f, ":t"), ft, detail))
  else
    failed = true
    io.stderr:write(string.format("FAIL  %-14s %-11s %s\n", vim.fn.fnamemodify(f, ":t"), ft, err))
  end
end

vim.cmd(failed and "cq!" or "qa!")
LUA

XDG_CONFIG_HOME="$tmp" nvim --headless -l "$tmp/probe.lua" "${files[@]}" 2>&1
