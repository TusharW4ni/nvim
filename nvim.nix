{ pkgs, ... }:
let
  # conform: mixed list+kwargs table. `__unkeyed-N` become positional list
  # entries in the generated Lua; `stop_after_first` stays a keyword.
  prettierChain = {
    "__unkeyed-1" = "prettierd";
    "__unkeyed-2" = "prettier";
    stop_after_first = true;
  };
  # Where ts_ls finds the @vue/typescript-plugin. Was a Mason path; nixpkgs
  # ships a pnpm layout, so point at the @vue/language-server package dir
  # (it has node_modules/@vue/typescript-plugin alongside).
  vueLsPath = "${pkgs.vue-language-server}/lib/language-tools/packages/language-server";
in
{
  programs.nixvim = {
    enable = true;

    # Reuse the system pkgs (from useGlobalPkgs) instead of nixvim importing
    # its own nixpkgs. Needed so copilot.vim inherits the system
    # allowUnfree = true; also avoids a second nixpkgs evaluation.
    nixpkgs.useGlobalPackages = true;

    # Runtime tools nvim shells out to: LSP servers, formatters, node for
    # copilot.vim + prettier. Replaces everything Mason used to fetch.
    extraPackages = with pkgs; [
      lua-language-server
      vue-language-server
      typescript-language-server
      typescript
      stylua
      prettierd
      prettier
      nodejs
    ];

    # vim.lsp.config/enable read default server definitions from nvim-lspconfig's
    # lsp/ runtime dir. We only need it on rtp, not its setup() framework.
    extraPlugins = [ pkgs.vimPlugins.nvim-lspconfig ];

    globals = {
      mapleader = " ";
      copilot_no_tab_map = false;
    };

    opts = {
      splitbelow = true;
      splitright = true;
      clipboard = "unnamedplus";
      laststatus = 3;
      statusline = "%#StatusLineFile#  %f ";
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      undofile = true;
      scrolloff = 8;
      signcolumn = "yes";
    };

    highlight = {
      StatusLine.bg = "NONE";
      StatusLineFile = {
        fg = "#c0caf5";
        bg = "NONE";
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>botright 15new | term<cr>i";
      }
      # oil
      {
        mode = "n";
        key = "-";
        action = "<cmd>Oil<cr>";
        options.desc = "Open parent directory (oil)";
      }
      # conform format
      {
        mode = [ "n" "v" ];
        key = "<leader>cf";
        action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end";
        options.desc = "Format buffer";
      }
      # which-key buffer-local
      {
        mode = "n";
        key = "<leader>?";
        action.__raw = "function() require('which-key').show({ global = false }) end";
        options.desc = "Buffer local keymaps";
      }
      # copilot: <Plug> mappings require remap
      {
        mode = "i";
        key = "<C-l>";
        action = "<Plug>(copilot-accept-word)";
        options = { remap = true; desc = "Copilot accept word"; };
      }
      {
        mode = "i";
        key = "<C-j>";
        action = "<Plug>(copilot-accept-line)";
        options = { remap = true; desc = "Copilot accept line"; };
      }
      {
        mode = "i";
        key = "<M-]>";
        action = "<Plug>(copilot-next)";
        options = { remap = true; desc = "Copilot next"; };
      }
      {
        mode = "i";
        key = "<M-[>";
        action = "<Plug>(copilot-previous)";
        options = { remap = true; desc = "Copilot previous"; };
      }
      {
        mode = "i";
        key = "<C-e>";
        action = "<Plug>(copilot-dismiss)";
        options = { remap = true; desc = "Copilot dismiss"; };
      }
    ];

    plugins = {
      # --- completion ---
      friendly-snippets.enable = true;
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "default";
          appearance = {
            use_nvim_cmp_as_default = true;
            nerd_font_variant = "mono";
          };
          sources.default = [ "lsp" "path" "snippets" "buffer" ];
        };
      };

      # --- copilot ---
      copilot-vim.enable = true;

      # --- fuzzy finder ---
      telescope = {
        enable = true;
        extensions.fzf-native = {
          enable = true;
          settings = {
            fuzzy = true;
            override_generic_sorter = true;
            override_file_sorter = true;
            case_mode = "smart_case";
          };
        };
        keymaps = {
          "<leader>ff" = { action = "find_files"; options.desc = "Telescope find files"; };
          "<leader>fg" = { action = "live_grep"; options.desc = "Telescope live grep"; };
          "<leader>fb" = { action = "buffers"; options.desc = "Telescope buffers"; };
          "<leader>fh" = { action = "help_tags"; options.desc = "Telescope help tags"; };
        };
      };

      # --- treesitter ---
      # Grammars come from nix (default set), so no auto_install / ensure needed.
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      # --- file explorer ---
      oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          view_options.show_hidden = true;
          keymaps."q" = "actions.close";
        };
      };

      # --- git ---
      gitsigns = {
        enable = true;
        settings.on_attach.__raw = ''
          function(bufnr)
            local gs = require('gitsigns')
            local function map(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            map('n', ']c', function()
              if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
            end, 'Next hunk')
            map('n', '[c', function()
              if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
            end, 'Prev hunk')

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
            map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
            map('n', '<leader>gd', gs.diffthis, 'Diff this')
            map('n', '<leader>gt', gs.toggle_current_line_blame, 'Toggle line blame')

            map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
          end
        '';
      };

      # --- which-key ---
      which-key.enable = true;

      # --- formatter ---
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            javascript = prettierChain;
            typescript = prettierChain;
            javascriptreact = prettierChain;
            typescriptreact = prettierChain;
            vue = prettierChain;
            css = prettierChain;
            html = prettierChain;
            json = prettierChain;
            jsonc = prettierChain;
            markdown = prettierChain;
            yaml = prettierChain;
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback";
          };
        };
      };
    };

    # Imperative bits that don't map cleanly to nixvim options: native LSP
    # config + LspAttach maps, which-key group names, and the centering plugin.
    extraConfigLua = ''
      -- ================= LSP =================
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      vim.lsp.config("vue_ls", { capabilities = capabilities })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = "${vueLsPath}",
              languages = { "vue" },
            },
          },
        },
        filetypes = { "javascript", "typescript", "vue" },
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.enable("vue_ls")
      vim.lsp.enable("ts_ls")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Docs" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Variable" }))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
        end,
      })

      -- ============ which-key groups ============
      require('which-key').add({
        { '<leader>f', group = 'Find' },
        { '<leader>c', group = 'Code' },
        { '<leader>r', group = 'Rename/Refactor' },
        { '<leader>t', group = 'Terminal' },
        { '<leader>g', group = 'Git' },
      })

      -- ============ :Center (from plugin/center.lua) ============
      local ratio = 1 / 2
      local pads = {}

      local function close_pads()
        for _, w in ipairs(pads) do
          if vim.api.nvim_win_is_valid(w) then vim.api.nvim_win_close(w, true) end
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
          if vim.o.diff then return end
          if vim.fn.argc() > 1 then return end
          if #vim.api.nvim_tabpage_list_wins(0) > 1 then return end
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
    '';
  };
}
