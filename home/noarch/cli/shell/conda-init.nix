{config, ...}: let
  # miniconda initialize
  condaDir = "${config.home.homeDirectory}/miniconda3";

  condaFish = ''
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    if test -f ${condaDir}/bin/conda
        eval ${condaDir}/bin/conda "shell.fish" "hook" $argv | source
    else
        if test -f "${condaDir}/etc/fish/conf.d/conda.fish"
            . "${condaDir}/etc/fish/conf.d/conda.fish"
        else
            set -x PATH "${condaDir}/bin" $PATH
        end
    end
    # <<< conda initialize <<<
  '';

  condaZsh = ''
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('${condaDir}/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "${condaDir}/etc/profile.d/conda.sh" ]; then
            . "${condaDir}/etc/profile.d/conda.sh"
        else
            export PATH="${condaDir}/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
  '';
in {
  programs.zsh.initContent = condaZsh;
  programs.fish.interactiveShellInit = condaFish;
}
