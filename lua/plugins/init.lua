return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Runs before the plugin loads, which is the only window in which the shim can patch
    -- `vim.treesitter.query.add_{predicate,directive}` ahead of nvim-treesitter registering
    -- its own. See lua/configs/ts-compat.lua.
    init = function()
      require "configs.ts-compat"
    end,
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
        "markdown_inline",
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
        "objc",
        "swift",
        "go",
        "rust",
        "python",
        "gdscript",
        "haskell",
        "zig",
        -- "ocaml",
        "sql",
        "nix",
        "fsharp",

        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- uncomment for format on save
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
    -- Must be an *extending* opts function. `config` returning a table performed no setup at
    -- all, and a plain `opts` table is discarded because NvChad's own spec uses
    -- `opts = function() return <its table> end`, which ignores what came before it.
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts or {}, require "configs.mason")
    end,
  },

  -- In-buffer rendering. Needs the markdown + markdown_inline parsers above.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Markdown toggle render" },
    },
  },
  -- Live preview in the browser. Built with npm rather than `mkdp#util#install`, whose
  -- prebuilt binary is dynamically linked and will not run on NixOS without nix-ld.
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function(plugin)
      if vim.fn.executable "npm" == 1 then
        vim.fn.system { vim.fn.exepath "npm", "install", "--prefix", plugin.dir .. "/app" }
      else
        vim.fn["mkdp#util#install"]()
      end
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Markdown toggle browser preview" },
    },
  },

  {
    "ionide/Ionide-vim",
    ft = { "fsharp", "fsharp_project" },
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      -- Must be set before the plugin loads: `loadConfig` reads these to build the
      -- server cmd, and `lsp_auto_setup = 0` stops Ionide enabling itself so the
      -- `config` below owns the client.
      vim.g["fsharp#lsp_auto_setup"] = 0
      vim.g["fsharp#show_signature_on_cursor_move"] = 0
      vim.g["fsharp#workspace_mode_peek_deep_level"] = 4
    end,
    config = function()
      -- NOTE: no `capabilities`/`on_init` here. NvChad's `defaults()` already applies both
      -- to every server via `vim.lsp.config("*", ...)`, and Ionide's own on_init runs
      -- fsharp#initialize() plus the workspace/didChangeConfiguration push -- `vim.lsp.config`
      -- merges plain functions with force semantics, so setting on_init here would replace
      -- it outright and silently break project loading. Keymaps likewise come from NvChad's
      -- global LspAttach autocmd, so on_attach only needs to restore the codelens refresh
      -- that overriding Ionide's own on_attach costs us.
      vim.lsp.config("ionide", {
        on_attach = function(_, bufnr)
          -- Setting on_attach here replaces Ionide's own, which is what would otherwise
          -- turn codelens on -- so redo it. `enable` supersedes the deprecated
          -- `codelens.refresh`, and nvim debounces re-requests on buffer change itself,
          -- so this needs no accompanying autocmd.
          vim.lsp.codelens.enable(true, { bufnr = bufnr })
        end,
      })

      vim.lsp.enable "ionide"
    end,
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
