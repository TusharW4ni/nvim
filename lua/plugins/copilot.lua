return {
  'github/copilot.vim',
  event = 'InsertEnter',
  config = function()
    -- copilot.vim accepts the suggestion with <Tab> by default.
    -- Keep that behavior; just make sure Tab isn't silently swallowed
    -- elsewhere and give a couple of extra motions.
    vim.g.copilot_no_tab_map = false

    -- Accept the whole suggestion word-by-word / line-by-line.
    vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-word)', { desc = 'Copilot accept word' })
    vim.keymap.set('i', '<C-j>', '<Plug>(copilot-accept-line)', { desc = 'Copilot accept line' })

    -- Cycle suggestions.
    vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', { desc = 'Copilot next' })
    vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)', { desc = 'Copilot previous' })
    vim.keymap.set('i', '<C-e>', '<Plug>(copilot-dismiss)', { desc = 'Copilot dismiss' })
  end,
}
