#!/usr/bin/env bash
# Run a lazy.nvim command against *this repo* as the config, writing lazy-lock.json back
# here instead of into the deployed copy at ~/.config/nvim.
#
#   ./scripts/lazy.sh                 # sync: install missing, clean removed, update, rewrite lock
#   ./scripts/lazy.sh update          # update only
#   ./scripts/lazy.sh restore         # pin your install back to the versions in the lock
#   ./scripts/lazy.sh -i sync         # isolated: resolve latest + write the lock, install untouched
#
# NOT read-only by default. Without -i this shares ~/.local/share/nvim/lazy with your real
# nvim, so `update`/`sync` move the plugins your editor actually loads (and `sync` deletes
# ones no longer in the specs). That keeps the lock and your install consistent, which is
# normally what you want.
#
# -i / --isolated points the data, state and cache dirs at a temp dir, so the run clones
# every plugin fresh and throws it away -- the lock is the only thing that survives, and
# your installed plugins are untouched. Slower (full clone of every plugin, and nvim-treesitter
# compiles parsers), so it is opt-in.
#
# nvim derives its config dir from $XDG_CONFIG_HOME/$NVIM_APPNAME, and appends $NVIM_APPNAME
# to the data dir too -- so the appname has to stay "nvim" for the shared case to hit the real
# plugin dir, which means the config dir must be *named* nvim. Hence the throwaway symlink.
# Nothing under ~/.config is touched either way.
set -euo pipefail

isolated=0
if [[ "${1:-}" == "-i" || "${1:-}" == "--isolated" ]]; then
  isolated=1
  shift
fi
cmd="${1:-sync}"

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ln -s "$repo" "$tmp/nvim"

# Snapshot the lock as it stands *now*, not as it stands in HEAD -- the working tree may
# already carry lock changes, and we only want to report what this run did.
cp "$repo/lazy-lock.json" "$tmp/before.json" 2>/dev/null || : >"$tmp/before.json"

env_args=(XDG_CONFIG_HOME="$tmp")
if [[ $isolated -eq 1 ]]; then
  # `restore` pins plugins to the versions already in the lock. Doing that inside a temp dir
  # we are about to delete accomplishes nothing, and worse, the fresh dir has to be populated
  # by an `install` first -- which resolves to latest and rewrites the lock (lazy only honours
  # the lock on checkout for `restore` itself, see manage/task/git.lua). So the lock would be
  # clobbered before restore ever read it. Refuse rather than silently produce a latest-lock.
  if [[ "$cmd" != "sync" && "$cmd" != "update" ]]; then
    echo "error: -i supports only 'sync' or 'update' (got '$cmd')." >&2
    echo "       Isolated mode exists to resolve plugins at latest and write the lock." >&2
    echo "       To pin your real install back to the lock, drop -i: ./scripts/lazy.sh restore" >&2
    exit 2
  fi
  mkdir -p "$tmp/data" "$tmp/state" "$tmp/cache"
  env_args+=(XDG_DATA_HOME="$tmp/data" XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache")
  echo "isolated run: cloning plugins into a temp dir, your install is untouched"
  # A fresh data dir has nothing installed, so `update` alone would have no plugins to act on.
  cmd=sync
fi

# `Lazy!` (with the bang) runs blocking, which is what makes it usable headlessly.
env "${env_args[@]}" nvim --headless "+Lazy! $cmd" +qa

if diff -q "$tmp/before.json" "$repo/lazy-lock.json" >/dev/null 2>&1; then
  echo "lazy-lock.json unchanged by '$cmd'"
else
  echo "lazy-lock.json changed by '$cmd':"
  diff --unified=0 "$tmp/before.json" "$repo/lazy-lock.json" | grep -E '^[-+]  "' || true
fi
