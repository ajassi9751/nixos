{ inputs, ... }: {
  flake.nixosModules.neovim-config =
    {
      pkgs,
      pkgs-unstable,
      ...
    }:
    {
      programs.neovim = {
        enable = true;
        # vimAlias = true;
        defaultEditor = true;
        withPython3 = false;
        withRuby = false;
        configure = {
          customLuaRC = ''
            -- Clipboard
            if vim.fn.has("wayland") == 1 then
              vim.g.clipboard = {
                name = "wl-clipboard",
                copy = {
                  ["+"] = "wl-copy",
                  ["*"] = "wl-copy",
                },
                paste = {
                  ["+"] = "wl-paste",
                  ["*"] = "wl-paste",
                },
              }
            end

            -- Theme
            vim.cmd.colorscheme("gruvbox")
            vim.opt.background = "dark"

            -- Treesitter
            vim.api.nvim_create_autocmd("FileType", {
              callback = function()
                pcall(vim.treesitter.start)
              end,
            })

            -- LSP
            vim.lsp.config('*', {
              capabilities = require('cmp_nvim_lsp').default_capabilities(),
            })

            vim.lsp.config('lua_ls', {
              cmd = { "${pkgs-unstable.lua-language-server}/bin/lua-language-server" },
              settings = {
                Lua = {
                  runtime = { special = { vim = "vim" } },
                  diagnostics = { globals = { "vim" } },
                },
              },
            })

            vim.lsp.config('rust_analyzer', {
              cmd = { "${pkgs-unstable.rust-analyzer}/bin/rust-analyzer" },
              settings = {
                ['rust-analyzer'] = {
                  checkOnSave = { command = "clippy" },
                },
              },
            })

            vim.lsp.config('clangd', {
              cmd = { "${pkgs-unstable.clang-tools}/bin/clangd" },
            })

            vim.lsp.config('pyright', {
              cmd = { "${pkgs-unstable.pyright}/bin/pyright-langserver", "--stdio" },
            })

            vim.lsp.config('nixd', {
              cmd = { "${pkgs.nixd}/bin/nixd" },
              settings = {
                nixd = {
                  nixpkgs = { expr = "import <nixpkgs> { }" },
                },
              },
            })

            vim.lsp.enable({'lua_ls', 'rust_analyzer', 'clangd', 'pyright', 'nixd'})

            -- Completion
            local cmp = require("cmp")
            cmp.setup({
              snippet = {
                expand = function(args)
                  require("luasnip").lsp_expand(args.body)
                end,
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
              }, {
                { name = "buffer" },
                { name = "path" },
              }),
            })

            -- Oil
            require("oil").setup({
              view_options = { show_hidden = true },
            })

            -- Flash
            require("flash").setup()

            -- Gitsigns
            require("gitsigns").setup()
          '';
          packages.myVimPackage = with pkgs.vimPlugins; {
            start = [
              nvim-treesitter.withAllGrammars
              nvim-cmp
              cmp-nvim-lsp
              cmp-buffer
              cmp-path
              luasnip
              telescope-nvim
              plenary-nvim
              oil-nvim
              flash-nvim
              gitsigns-nvim
              gruvbox-nvim
            ];
          };
        };
      };
    };
}
