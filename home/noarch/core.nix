{
  config,
  lib,
  username,
  pkgs,
  ...
}: {
  imports = [
    ./brewery.nix
  ];

  options.dotfilesRoot = lib.mkOption {
    type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
    default = "${config.home.homeDirectory}/pluto.nix";
    defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/pluto.nix"'';
    example = "/Users/pluto/src/pluto.nix";
    description = ''
      Absolute checkout path used for live configuration symlinks.
      Use a string rather than a Nix path literal to avoid copying the checkout
      into the Nix store. The directory does not need to exist during evaluation.
    '';
  };

  config = {
    _module.args = {
      isFormula = name:
        if builtins.elem name config.brewery.rules.brewList
        then builtins.warn "[brewery] ${name}: package installation is managed by Homebrew (formula)" true
        else false;
      isCask = name:
        if builtins.elem name config.brewery.rules.caskList
        then builtins.warn "[brewery] ${name}: package installation is managed by Homebrew (cask)" true
        else false;
    };

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home = {
      inherit username;

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      stateVersion = "24.11";

      # Tools for maintaining this configuration, independent of optional CLI modules.
      packages = with pkgs; [
        nil # Nix language server
        nixd # Nix language server with module option completion
        statix # Lints and suggestions for the nix programming language
        deadnix # Find and remove unused code in .nix source files
        alejandra # Nix Code Formatter
      ];
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
