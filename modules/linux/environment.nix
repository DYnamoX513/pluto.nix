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
    agenix.packages.${system}.default # agenix CLI
  ];

  # in global environment
  environment.variables = {
    # EDITOR = "nvim";
    EDITOR = "hx";
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}
