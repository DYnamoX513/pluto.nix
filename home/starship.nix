{lib, ...}: {
  programs.starship = {
    enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;

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
  };

  home.activation.tipDisableCondaPS1 = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Starship does not suppress conda's own prompt modifier, you may want to run conda config --set changeps1 False"
  '';
}
