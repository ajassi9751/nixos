{ inputs, ... }: {
  flake.nixosModules.nvf-config = { ... }: {
    imports = [ inputs.nvf.nixosModules.default ];

    # NVF config
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          theme = {
            enable = true;
            name = "gruvbox";
            style = "dark";
            # Hopefully doesn't conflict and instead compliments terminal transparency
            transparent = true;
          };
          clipboard.enable = true;
          vimAlias = false;
          lsp.enable = true;
          telescope.enable = true;
          autocomplete.nvim-cmp.enable = true;
          utility.oil-nvim.enable = true;
          utility.motion.flash-nvim.enable = true;
          git.gitsigns.enable = true;
          languages = {
            enableTreesitter = true;
            rust.enable = true;
            nix.enable = true;
            clang.enable = true;
            lua.enable = true;
            make.enable = true;
            cmake.enable = true;
            python.enable = true;
          };
        };
      };
    };
  };
}
