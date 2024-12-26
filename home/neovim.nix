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
      # enable = true;

      # defaultEditor = true; # set EDITOR at system-wide level
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # These environment variables are needed to build and run binaries
      # with external package managers like mason.nvim.
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
    };
  };
}
