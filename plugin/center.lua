-- ~/.config/nvim/plugin/center.lua
local ratio = 1 / 2        -- fraction of the screen the content occupies
local pads = {}

local function close_pads()
  for _, w in ipairs(pads) do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_close(w, true)
    end
  end
  pads = {}
end

local function open_pads()
  close_pads()
  local content = math.floor(vim.o.columns * ratio)
  if content < 60 then return end
  local side = math.floor((vim.o.columns - math.floor(vim.o.columns * ratio)) / 2)
  if side < 1 then return end

  local main = vim.api.nvim_get_current_win()

  for _, cmd in ipairs({ "topleft vsplit", "botright vsplit" }) do
    vim.cmd(cmd)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_win_set_width(win, side)

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].cursorline = false
    vim.wo[win].winfixwidth = true
    vim.wo[win].fillchars = "eob: "
    vim.wo[win].statusline = " "
    vim.wo[win].winhighlight = "StatusLine:Normal,StatusLineNC:Normal,WinSeparator:Normal"

    pads[#pads + 1] = win
  end

  vim.api.nvim_set_current_win(main)
end

vim.api.nvim_create_user_command("Center", function()
  if #pads > 0 then close_pads() else open_pads() end
end, {})

vim.api.nvim_create_user_command("CenterRatio", function(o)
  ratio = tonumber(o.args) or ratio
  if #pads > 0 then open_pads() end
end, { nargs = 1 })

vim.api.nvim_create_autocmd("VimResized", {
  callback = function() if #pads > 0 then open_pads() end end,
})

vim.keymap.set("n", "<leader>z", "<cmd>Center<cr>", { desc = "Center buffer" })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.o.diff then return end                              -- nvim -d
    if vim.fn.argc() > 1 then return end                       -- nvim -O a b
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then return end  -- already split
    if vim.bo[vim.api.nvim_get_current_buf()].buftype ~= "" then return end
    vim.schedule(open_pads)
  end,
})

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local is_pad = {}
    for _, w in ipairs(pads) do is_pad[w] = true end

    local real = 0
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if not is_pad[w] and vim.api.nvim_win_get_config(w).relative == "" then
        real = real + 1
      end
    end

    if real <= 1 then close_pads() end
  end,
})
