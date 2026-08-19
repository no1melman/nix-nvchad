-- Compatibility shim: nvim-treesitter's `master` branch on Neovim 0.12.
--
-- master is archived and supports Neovim 0.10/0.11 only. Its predicates and directives
-- (`lua/nvim-treesitter/query_predicates.lua`) all register with `{ all = false }` -- the
-- 0.10-era option that made a match arrive as `capture id -> TSNode`. Neovim 0.12 dropped
-- `all` entirely: handlers now always receive `capture id -> TSNode[]`, so nvim-treesitter's
-- handlers call node methods on a plain list. Opening any markdown file with a fenced code
-- block dies inside `#set-lang-from-info-string!` with
--
--   .../runtime/lua/vim/treesitter.lua:197: attempt to call method 'range' (a nil value)
--
-- taking the highlighter's parse with it. bash, hcl, html, hurl, php and ruby injections
-- lean on the same directives.
--
-- Rather than reimplement each handler, restore the option: wrap `add_predicate` /
-- `add_directive` so that a handler registered with `all = false` is handed the single
-- (last) node per capture again, exactly as 0.11 did. This has to run before
-- nvim-treesitter registers anything, hence the `init` hook on its plugin spec.
--
-- Remove this once nvim-treesitter moves to its `main` branch (which speaks the 0.12 API).

local query = require "vim.treesitter.query"

if vim.fn.has "nvim-0.12" ~= 1 or query._nvchad_all_compat then
  return
end

query._nvchad_all_compat = true

---@param match table<integer, TSNode[]>
---@return table<integer, TSNode>
local function last_per_capture(match)
  local single = {}
  for id, nodes in pairs(match) do
    -- 0.11 handed over the *last* node captured by each capture id; keep that behaviour.
    single[id] = type(nodes) == "table" and nodes[#nodes] or nodes
  end
  return single
end

---@param add fun(name: string, handler: function, opts: table|boolean|nil)
local function honour_all_false(add)
  return function(name, handler, opts)
    if type(opts) == "table" and opts.all == false then
      local inner = handler
      handler = function(match, ...)
        return inner(last_per_capture(match), ...)
      end
    end

    return add(name, handler, opts)
  end
end

query.add_predicate = honour_all_false(query.add_predicate)
query.add_directive = honour_all_false(query.add_directive)
