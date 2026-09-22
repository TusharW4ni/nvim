return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      -- Simply provide the language array directly inside opts
      ensure_installed = { 
        "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
        "vue", "html", "css", "javascript", "typescript"
      },
      auto_install = true,
      highlight = { enable = true },
    },
    config = function(_, opts)
      -- Call the modern configuration entry (without the trailing 's')
      require("nvim-treesitter.config").setup(opts)
    end,
  }
}

