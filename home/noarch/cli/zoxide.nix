{
  lib,
  isFormula,
  ...
}:
with lib; let
  brewed = isFormula "zoxide";
in
  mkMerge [
    {
      programs.zoxide.enable = !brewed;
    }

    (mkIf (!brewed) {
      programs.zoxide = {
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    })

    (mkIf brewed {
      programs.zsh.initContent = ''
        eval "$(zoxide init zsh)"
      '';

      programs.fish.interactiveShellInit = ''
        zoxide init fish | source
      '';
    })
  ]
