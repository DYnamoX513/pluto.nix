{
  username,
  scanPaths,
  pkgs,
  osConfig,
  ...
}: let
  brewNames = builtins.map (brew: brew.name) osConfig.homebrew.brews;
  caskNames = builtins.map (brew: brew.name) osConfig.homebrew.casks;
  homebrewPackages = brewNames ++ caskNames;

  enabledByHomebrew = caskOrFormula: builtins.elem caskOrFormula homebrewPackages;
in {
  # import sub modules
  imports = scanPaths ./.;

  _module.args = {inherit enabledByHomebrew;};

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";

    packages = with pkgs; [
      # nil # LSP. install it through mason
      # nixd # LSP
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      alejandra # Nix Code Formatter
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.thefuck = {
    enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;
  };
}
