{
  pkgs,
  agenix,
  ...
}: {
  ##########################################################################
  #
  #  Install all packages here and set environment variables.
  #
  ##########################################################################

  environment.systemPackages = with pkgs; [
    neovim
    helix
    git
    just
    agenix.packages.${stdenv.hostPlatform.system}.default # agenix CLI
  ];

  # in global environment
  environment.variables = {
    # EDITOR = "nvim";
    EDITOR = "hx";
    # LANG = "en_US.UTF-8";
    # LC_CTYPE = "en_US.UTF-8";
    # LC_ALL = "en_US.UTF-8";
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
}
