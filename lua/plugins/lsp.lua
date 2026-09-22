return {
  -- 1. Setup the Autocompletion Engine (blink.cmp)
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "^1",
    opts = {
      keymap = { preset = "default" },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- 2. Setup LSP Configuration via Native API
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Bootstrap Mason packages
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "vue_ls", "ts_ls" },
      })

      -- Grab modern integration capabilities from blink
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- --- MODERN NATIVE LSP CONFIGS ---
      -- We now bind directly onto vim.lsp.config instead of lspconfig framework

      -- Lua configuration
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- Vue (Volar) configuration.
      -- Volar 3.x runs in "hybrid mode": it handles the template/styles and
      -- delegates TypeScript work to ts_ls via the @vue/typescript-plugin below.
      -- Use the shipped defaults (filetype = vue only) so nvim-lspconfig's
      -- hybrid handshake with ts_ls stays intact.
      vim.lsp.config("vue_ls", {
        capabilities = capabilities,
      })

      -- ts_ls loads the Vue TS plugin so it understands .vue files instead of
      -- parsing them as raw TypeScript (which caused an error on every line).
      local vue_ls_path = vim.fn.stdpath("data")
        .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_ls_path,
              languages = { "vue" },
            },
          },
        },
        filetypes = { "javascript", "typescript", "vue" },
      })

      -- --- ENABLE THE CONFIGS ---
      -- You must explicitly call vim.lsp.enable to boot the servers up
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("vue_ls")
      vim.lsp.enable("ts_ls")

      -- --- GLOBAL LSP SHORTCUTS ---
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr, silent = true }

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Docs" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Variable" }))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
        end,
      })
    end,
  },
}

