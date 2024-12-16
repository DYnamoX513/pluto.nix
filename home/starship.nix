{ ... }: {
  programs.starship = {
    enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;
settings = {
    format = "$all$directory$character";
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
  };
  };
}
