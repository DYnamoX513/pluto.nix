{config, lib,pkgs,...}:
let 
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

    # cargo
    cargo = shell:
         if shell == "fish" then
    "fish_add_path $HOME/.cargo/bin"
        else
            ''. "$HOME/.cargo/env"''
        ;

    # orbstack
    orbstack = shell:
        ''
# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.${shell} 2>/dev/null || :
    '';

    # homebrew
    homebrew = shell: ''eval "$(${config.homebrew.brewPrefix}/brew shellenv ${shell})"'';

    # ~/Library/Application\ Support/JetBrains/Toolbox/scripts/... E.g., clion

 #    # language - English
 #    lang = shell: 
 #    if shell == "fish" then
 #        ''
 #    set -gx LANG en_US.UTF-8
 #    set -gx LC_CTYPE en_US.UTF-8
 #    set -gx LC_ALL en_US.UTF-8
 #    ''
 #    else 
 #        ''
 # export LANG="en_US.UTF-8"
 # export LC_CTYPE="en_US.UTF-8"
 # export LC_ALL="en_US.UTF-8"
 #        '';

    # wezterm completion
    wezterm = shell: ''eval "$(wezterm shell-completion --shell ${shell})"'';

        # brew + orbstack + cargo + language
    commonLogin = shell :
           [
(orbstack shell)
            (cargo shell)
            (homebrew shell)
        ];
    commonInteractive = shell:
        [
        ]
        ;

    # fancy fish greeting
in
{

    programs.zsh = {
        enable = true;
        # instead, use zsh-autocompletion https://github.com/marlonrichert/zsh-autocomplete
        enableCompletion = false;
        # zsh-autosuggestions
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
oh-my-zsh = {
            enable = true;
theme = "robbyrussell";
            plugins = [
"git"
                # easily prefix your current or previous commands with sudo by pressing esc twice
                "sudo"
            ];
        };
        plugins=[
  {
    name = "zsh-autocomplete";
    src = pkgs.fetchFromGitHub {
      owner = "marlonrichert";
      repo = "zsh-autocomplete";
      rev = "24.09.04";
      sha256 = "";
    };
  }

];
profileExtra = lib.strings.concatLines commonLogin "zsh";
        initExtra = lib.strings.concatLines 
            commonInteractive "zsh" ++ [
            condaZsh
        ];
    };

    programs.fish = {
enable = true;
loginShellInit = lib.strings.concatLines commonLogin "fish";
interactiveShellInit = 
         lib.strings.concatLines 
            commonInteractive "fish" ++ [
                condaFish
                (wezterm "fish") # no enableFishIntegration for wezterm (24.11)
        ];
        functions = {
            # yazi change cwd
yy = {
body = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
            '';
        };
            # switch to java 8
            java8 = {
body = ''
    set -gx JAVA_HOME (/usr/libexec/java_home -v 1.8)
    echo "JAVA_HOME set to $JAVA_HOME"
    java -version
                '';
            };
            # unset JAVA_HOME
            unset_java = {
body = ''
    set -e JAVA_HOME
    echo "JAVA_HOME has been unset"
            '';
            };
        };
    };
}
