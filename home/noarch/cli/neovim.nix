{
  config,
  lib,
  pkgs,
  isFormula,
  ...
}:
# Use customized NvChad-starter
let
  brewed = isFormula "neovim";
  # the path to nvim directory
  configPath = "${config.dotfilesRoot}/share/nvim";

  aliases = {
    vi = "nvim";
    vim = "nvim";
    vimdiff = "nvim -d";
  };
in
  lib.mkMerge [
    {
      # Use Nix Neovim only when Homebrew does not manage it.
      programs.neovim.enable = !brewed;
      xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink configPath;
    }
    (lib.mkIf (!brewed) {
      programs.neovim = {
        enable = true;

        withRuby = false;
        withPython3 = false;

        # Fix error like "installing file '.config/nvim/init.lua' outside $HOME"
        # See https://github.com/nix-community/home-manager/issues/8938
        sideloadInitLua = true;

        # defaultEditor = true;

        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        # package = pkgs.neovim-unwrapped;
        # These environment variables are needed to build and run binaries
        # with external package managers like mason.nvim.
        #
        # On NixOS, nix-ld uses NIX_LD_LIBRARY_PATH for unpatched executables.
        # Nix-built interpreters do not automatically use those paths for native modules;
        # they may need a dedicated wrapper. nix-ld does not supply build-time headers.
        # extraWrapperArgs = with pkgs; [
        #   # LIBRARY_PATH is used by gcc before compilation to search directories
        #   # containing static and shared libraries that need to be linked to your program.
        #   "--suffix"
        #   "LIBRARY_PATH"
        #   ":"
        #   "${lib.makeLibraryPath [stdenv.cc.cc zlib]}"
        #
        #   # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
        #   # containing .pc files that describe the libraries that need to be linked to your program.
        #   "--suffix"
        #   "PKG_CONFIG_PATH"
        #   ":"
        #   "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [stdenv.cc.cc zlib]}"
        # ];
      };
    })
    (lib.mkIf brewed {
      programs.zsh.shellAliases = aliases;
      programs.fish = with lib;
        mkMerge [
          (mkIf (!config.programs.fish.preferAbbrs) {shellAliases = aliases;})
          (mkIf config.programs.fish.preferAbbrs {shellAbbrs = aliases;})
        ];
    })
  ]
