{
  config,
  lib,
  isFormula,
  ...
}:
with lib; let
  brewed = isFormula "yazi";

  cfg = config.programs.yazi;
  bashIntegration = ''
    function ${cfg.shellWrapperName}() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';

  fishIntegration = ''
    function ${cfg.shellWrapperName}
      set tmp (mktemp -t "yazi-cwd.XXXXX")
      yazi $argv --cwd-file="$tmp"
      if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
      end
      rm -f -- "$tmp"
    end
  '';
in
  mkMerge [
    {
      programs.yazi.enable = !brewed;
    }

    (mkIf (!brewed) {
      programs.yazi = {
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    })

    (mkIf brewed {
      programs.zsh.initExtra = bashIntegration;
      programs.fish.interactiveShellInit =
        fishIntegration;
    })
  ]
