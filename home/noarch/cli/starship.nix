{
  pkgs,
  lib,
  isFormula,
  ...
}: let
  brewed = isFormula "starship";
  tomlFormat = pkgs.formats.toml {};
  settings = {
    format = "$directory$fill$all$line_break$shell$character";
    right_format = "$time";
    time = {
      disabled = false;
      style = "dimmed white";
      format = "[$time]($style) ";
      time_format = "%T";
    };
    line_break = {
      disabled = false;
    };
    character = {
      success_symbol = "[󱥌 ](bold green)";
      error_symbol = "[󱥍 ](bold red)";
    };
    localip = {
      ssh_only = false;
      disabled = false;
    };
    hostname = {
      disabled = false;
    };
    shell = {
      disabled = false;
    };
    conda = {
      ignore_base = false;
    };
  };
in
  lib.mkMerge [
    {
      # use nixpkgs-lazygit only if it's not added to brew list
      programs.starship.enable = !brewed;
      home.activation.tipDisableCondaPS1 = lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Starship does not suppress conda's own prompt modifier, you may want to run conda config --set changeps1 False"
      '';
    }
    (lib.mkIf (!brewed) {
      programs.starship = {
        enableFishIntegration = true;
        enableZshIntegration = true;
        inherit settings;
      };
    })
    (lib.mkIf brewed {
      xdg.configFile."starship.toml" = lib.mkIf (settings != {}) {
        source = tomlFormat.generate "starship-config" settings;
      };

      programs.zsh.initExtra = ''
        if [[ $TERM != "dumb" ]]; then
          eval "$(starship init zsh)"
        fi
      '';

      programs.fish.interactiveShellInit = ''
        if test "$TERM" != "dumb"
          eval (starship init fish)
        end
      '';
    })
  ]
