{
  config,
  osConfig,
  lib,
  ...
}: let
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
    if shell == "fish"
    then "fish_add_path -p $HOME/.cargo/bin" # prepend by default
    else ''. "$HOME/.cargo/env"'';

  # orbstack
  orbstack = shell: ''
    # Added by OrbStack: command-line tools and integration
    source ~/.orbstack/shell/init.${shell} 2>/dev/null || :
  '';

  # neovim mason installed binaries
  mason = shell:
    if shell == "fish"
    then
      # -a = append, but $fish_user_path is prepended to $PATH
      # results in $fish_user_path -> [mason] -> $PATH
      "fish_add_path -a $HOME/.local/share/nvim/mason/bin"
    else
      # prepend
      "export PATH=$HOME/.local/share/nvim/mason/bin:$PATH";

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

  # TODO: separate Darwin specific configurations into sub-modules

  # Homebrew shellenv:
  # This line not only sets PATH, but other variables like FPATH (zsh),
  # HOMEBREW_PREFIX, HOMEBREW_CELLAR and HOMEBREW_REPOSITORY as well.
  homebrew = shell: ''eval "$(${osConfig.homebrew.brewPrefix}/brew shellenv ${shell})"'';
  # However, as Homebrew `prepend` its bin paths, this can cause problems if a package
  # e.g., zoxide, is installed by both Homebrew and nix. (Especially when shell
  # integration is enabled in home-manager)

  # extra lines required by fish: https://docs.brew.sh/Shell-Completion
  homebrewCompletionForFish = ''
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
  '';

  # brew + orbstack + cargo + language
  commonLogin = shell: [
    (orbstack shell)
    (cargo shell)
    (mason shell)
  ];
  commonInteractive = shell: [
  ];
in {
  programs.zsh = {
    enable = true;
    # instead, use zsh-autocompletion https://github.com/marlonrichert/zsh-autocomplete
    # enableCompletion = false;
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
    plugins = [
      # {
      #   name = "zsh-autocomplete";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "marlonrichert";
      #     repo = "zsh-autocomplete";
      #     rev = "24.09.04";
      #     sha256 = "sha256-o8IQszQ4/PLX1FlUvJpowR2Tev59N8lI20VymZ+Hp4w=";
      #   };
      # }
    ];
    profileExtra = lib.strings.concatLines (commonLogin "zsh");
    initExtra = lib.strings.concatLines (
      commonInteractive "zsh"
      ++ [
        condaZsh
      ]
    );
    # make sure eval "$(brew shellenv)" is called before sourcing oh-my-zsh.sh
    # See https://docs.brew.sh/Shell-Completion
    initExtraBeforeCompInit = lib.strings.concatLines [
      (homebrew "zsh")
    ];
  };

  programs.fish = {
    enable = true;
    loginShellInit = lib.strings.concatLines ([(homebrew "fish")] ++ commonLogin "fish");
    interactiveShellInit = lib.strings.concatLines (
      commonInteractive "fish"
      ++ [
        condaFish
        (wezterm "fish") # no enableFishIntegration for wezterm (24.11)
        homebrewCompletionForFish
        # fancy fish greeting
        # "set -gu fish_greeting hello"
        /*
           ''
          set_color yellow; echo -n "...Landing on"; set_color normal
          echo -E "     ___                       ___                       ___
                       /  /\                     /__/\          ___        /  /\
                      /  /::\                    \  \:\        /  /\      /  /::\
                     /  /:/\:\  ___     ___       \  \:\      /  /:/     /  /:/\:\
                    /  /:/~/:/ /__/\   /  /\  ___  \  \:\    /  /:/     /  /:/  \:\
                   /__/:/ /:/  \  \:\ /  /:/ /__/\  \__\:\  /  /::\    /__/:/ \__\:\
                   \  \:\/:/    \  \:\  /:/  \  \:\ /  /:/ /__/:/\:\   \  \:\ /  /:/
                    \  \::/      \  \:\/:/    \  \:\  /:/  \__\/  \:\   \  \:\  /:/
                     \  \:\       \  \::/      \  \:\/:/        \  \:\   \  \:\/:/
                      \  \:\       \__\/        \  \::/          \__\/    \  \::/
                       \__\/                     \__\/                     \__\/
          "
        ''
        */
      ]
    );
    functions = {
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
