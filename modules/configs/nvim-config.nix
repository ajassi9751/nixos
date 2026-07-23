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
            vim.treesitter.start()

            -- LSP
            local lspconfig = require("lspconfig")

            lspconfig.lua_ls.setup({
              cmd = { "${pkgs-unstable.lua-language-server}/bin/lua-language-server" },
              settings = {
                Lua = {
                  runtime = { special = { vim = "vim" } },
                  diagnostics = { globals = { "vim" } },
                },
              },
            })

            lspconfig.rust_analyzer.setup({
              cmd = { "${pkgs-unstable.rust-analyzer}/bin/rust-analyzer" },
            })

            lspconfig.clangd.setup({
              cmd = { "${pkgs-unstable.clang-tools}/bin/clangd" },
            })

            lspconfig.pyright.setup({
              cmd = { "${pkgs-unstable.pyright}/bin/pyright-langserver", "--stdio" },
            })

            lspconfig.nil_ls.setup({
              cmd = { "${pkgs.nil}/bin/nil" },
            })

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
              nvim-lspconfig
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
