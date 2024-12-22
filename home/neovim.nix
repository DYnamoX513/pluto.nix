{
  config,
  lib,
  pkgs,
  ...
}:
# Use customized NvChad-starter
let
  # the path to nvim directory
  configPath = "${config.home.homeDirectory}/pluto.nix/share/nvim";
in {
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink configPath;

  programs = {
    neovim = {
      enable = true;

      # defaultEditor = true; # set EDITOR at system-wide level
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # We use brew's neovim on Darwin, configs below are unnecessary
      package = pkgs.neovim-unwrapped;

      # These environment variables are needed to build and run binaries
      # with external package managers like mason.nvim.
      #
      # LD_LIBRARY_PATH is also needed to run the non-FHS binaries downloaded by mason.nvim.
      # it will be set by nix-ld, so we do not need to set it here again.
      extraWrapperArgs = with pkgs; [
        # LIBRARY_PATH is used by gcc before compilation to search directories
        # containing static and shared libraries that need to be linked to your program.
        "--suffix"
        "LIBRARY_PATH"
        ":"
        "${lib.makeLibraryPath [stdenv.cc.cc zlib]}"

        # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
        # containing .pc files that describe the libraries that need to be linked to your program.
        "--suffix"
        "PKG_CONFIG_PATH"
        ":"
        "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [stdenv.cc.cc zlib]}"
      ];

      # Currently we use lazy.nvim as neovim's package manager, so comment this one.
      #
      # NOTE: These plugins will not be used by astronvim by default!
      # We should install packages that will compile locally or download FHS binaries via Nix!
      # and use lazy.nvim's `dir` option to specify the package directory in nix store.
      # so that these plugins can work on NixOS.
      #
      # related project:
      #  https://github.com/b-src/lazy-nix-helper.nvim
      # plugins = with pkgs.vimPlugins; [
      #   # search all the plugins using https://search.nixos.org/packages
      #   telescope-fzf-native-nvim
      #
      #   nvim-treesitter.withAllGrammars
      # ];
    };
  };
}
