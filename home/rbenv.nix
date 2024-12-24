{
  config,
  lib,
  ...
}:
# Improved rbenv module
{
  programs.rbenv = {
    enable = true;

    # in HM 24.11 (https://github.com/nix-community/home-manager/blob/80b0fdf483c5d1cb75aaad909bd390d48673857f/modules/programs/rbenv.nix#L89)
    # 1. bash integration -> initExtra -> .bashrc
    # 2. zsh integration -> initExtra -> .zshrc
    # 3. fish integration -> shellInit -> config.fish (no login or interactive check)
    # And all of them missing --no-rehash arg, which drastically slowdown the shell start-up

    enableFishIntegration = lib.mkForce false;
    enableZshIntegration = lib.mkForce false;
    enableBashIntegration = lib.mkForce false;
  };

  programs.zsh.initExtra =
    if config.programs.rbenv.enable
    then ''eval "$(${config.programs.rbenv.package}/bin/rbenv init - --no-rehash zsh)"''
    else null;

  programs.fish.interactiveShellInit =
    if config.programs.rbenv.enable
    then ''${config.programs.rbenv.package}/bin/rbenv init - --no-rehash fish | source''
    else null;
}
