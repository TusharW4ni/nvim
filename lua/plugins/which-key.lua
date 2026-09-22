return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function(_, opts)
    local wk = require('which-key')
    wk.setup(opts)

    -- Name the leader groups so the popup reads nicely
    wk.add({
      { '<leader>f', group = 'Find' },
      { '<leader>c', group = 'Code' },
      { '<leader>r', group = 'Rename/Refactor' },
      { '<leader>t', group = 'Terminal' },
      { '<leader>g', group = 'Git' },
    })
  end,
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show({ global = false })
      end,
      desc = 'Buffer local keymaps',
    },
  },
}
