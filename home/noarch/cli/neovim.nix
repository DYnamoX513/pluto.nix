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
  configPath = "${config.home.homeDirectory}/pluto.nix/share/nvim";

  aliases = {
    vi = "nvim";
    vim = "nvim";
    vimdiff = "nvim -d";
  };
in
  lib.mkMerge [
    {
      # use nixpkgs-lazygit only if it's not added to brew list
      programs.neovim.enable = !brewed;
      xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink configPath;
    }
    (lib.mkIf (!brewed) {
      programs.neovim = {
        enable = true;

        # defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        # package = pkgs.neovim-unwrapped;
        # These environment variables are needed to build and run binaries
        # with external package managers like mason.nvim.
        #
        # LD_LIBRARY_PATH is also needed to run the non-FHS binaries downloaded by mason.nvim.
        # it will be set by nix-ld, so we do not need to set it here again.
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
