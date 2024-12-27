{
  config,
  lib,
  isFormula,
  ...
}:
with lib; let
  brewed = isFormula "thefuck";
  cliArgs = cli.toGNUCommandLineShell {} {
    alias = true;
    enable-experimental-instant-mode = config.programs.thefuck.enableInstantMode;
  };
in
  mkMerge [
    {
      programs.thefuck.enable = !brewed;
    }

    (mkIf (!brewed) {
      programs.thefuck = {
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    })

    (mkIf brewed {
      programs.zsh.initExtra = ''
        eval "$(thefuck ${cliArgs})"
      '';
      programs.fish.functions = {
        fuck = {
          description = "Correct your previous console command";
          body = ''
            set -l fucked_up_command $history[1]
            env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
            if [ "$unfucked_command" != "" ]
              eval $unfucked_command
              builtin history delete --exact --case-sensitive -- $fucked_up_command
              builtin history merge
            end
          '';
        };
      };
    })
  ]
