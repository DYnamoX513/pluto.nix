{
  lib,
  isFormula,
  ...
}:
with lib; let
  brewed = isFormula "fzf";
in
  mkMerge [
    {
      programs.fzf.enable = !brewed;
    }

    (mkIf (!brewed) {
      programs.fzf = {
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    })

    (mkIf brewed {
      # Note, since fzf unconditionally binds C-r we use `mkOrder` to make the
      # initialization show up a bit earlier. This is to make initialization of
      # other history managers, like mcfly or atuin, take precedence.
      programs.zsh.initExtra = mkOrder 200 ''
        if [[ $options[zle] = on ]]; then
          eval "$(fzf --zsh)"
        fi
      '';

      programs.fish.interactiveShellInit = mkOrder 200 ''
        fzf --fish | source
      '';
    })
  ]
