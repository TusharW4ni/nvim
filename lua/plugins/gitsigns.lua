return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Navigate between hunks
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gs.nav_hunk('next')
        end
      end, 'Next hunk')
      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gs.nav_hunk('prev')
        end
      end, 'Prev hunk')

      -- Actions (under the <leader>g "Git" group)
      map('n', '<leader>gs', gs.stage_hunk, 'Stage hunk (toggle)')
      map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
      map('v', '<leader>gs', function()
        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, 'Stage selection')
      map('v', '<leader>gr', function()
        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, 'Reset selection')
      map('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
      map('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')
      map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
      map('n', '<leader>gb', function()
        gs.blame_line({ full = true })
      end, 'Blame line')
      map('n', '<leader>gd', gs.diffthis, 'Diff this')
      map('n', '<leader>gt', gs.toggle_current_line_blame, 'Toggle line blame')

      -- Text object: inner hunk (e.g. dih, vih)
      map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
    end,
  },
}
