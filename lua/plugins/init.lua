return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "svelte",

        "json",
        "yaml",
        "dockerfile",
        "terraform",
        "markdown",
        "mermaid",
        "proto",
        "cmake",
        "regex",
        "toml",

        "bash",
        "bicep",
        "c_sharp",
        "cpp",
        "c",
        "go",
        "rust",
        "python",
        "gdscript",
        "haskell",
        "zig",
        -- "ocaml",
        "sql",
        "nix",

        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        side = "right",
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
    },
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "mfussenegger/nvim-dap",
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "html-lsp",
        "stylua",
        "yaml-language-server",
        "lemminx",
        "typescript-language-server",
        "clangd",
        "gopls",
        "rust-analyzer",
        "svelte-language-server",
        "omnisharp",
        "powershell-editor-services",
        "css-lsp",
        "terraform-ls",
        "bicep-lsp",
        "dockerfile-language-server",
        -- formatters
        "prettier",
        "prettierd",
        "clang-format",
        "cmakelang",
        "fantomas",
        "yamlfmt",
        "goimports",
      },
    },
  },

  {
    "ionide/Ionide-vim",
    ft = "fsharp",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    event = "VeryLazy",
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
  },
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    dependencies = {
      {
        "tris203/rzls.nvim",
        config = true,
      },
    },
    init = function()
      vim.filetype.add {
        extension = {
          razor = "razor",
          cshtml = "cshtml",
        },
      }
    end,
  },
}
