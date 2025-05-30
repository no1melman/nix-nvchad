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
    "mason-org/mason.nvim",
    config = function()
      return require "configs.mason"
    end,
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
