local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    fsharp = { "fantomas" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    cmake = { "cmake_format" },
    terraform = { command = "terraform fmt", args = { "-write", "$FILENAME"} },
    -- Conform will run multiple formatters sequentially
    go = { "goimports", "gofmt" },
    -- Use a sub-list to run only the first available formatter
    javascript = { "prettierd", "prettier" },
    -- You can use a function here to determine the formatters dynamically
    python = function(bufnr)
      if require("conform").get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,

    nix = { "nixfmt" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
