{
  config,
  osConfig,
  lib,
  ...
}: let
  # orbstack
  orbstack = shell: ''
    # Added by OrbStack: command-line tools and integration
    source ~/.orbstack/shell/init.${shell} 2>/dev/null || :
  '';

  # ~/Library/Application\ Support/JetBrains/Toolbox/scripts/... E.g., clion

  # Homebrew shellenv:
  # This line not only sets PATH, but other variables like FPATH (zsh),
  # HOMEBREW_PREFIX, HOMEBREW_CELLAR and HOMEBREW_REPOSITORY as well.
  homebrew = shell: ''eval "$(${osConfig.homebrew.brewPrefix}/brew shellenv ${shell})"'';
  # However, as Homebrew `prepend` its bin paths, this can cause problems if a package
  # e.g., zoxide, is installed by both Homebrew and nix. (Especially when shell
  # integration is enabled in home-manager)

  preferNixOverBrew = shell:
    if shell == "fish"
    then "fish_add_path --global --move --path ${config.home.profileDirectory}/bin"
    else "export PATH=\"${config.home.profileDirectory}/bin:$PATH\"";

  # extra lines required by fish: https://docs.brew.sh/Shell-Completion
  homebrewCompletionForFish = ''
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
  '';

  # brew + orbstack
  commonLogin = shell: [
    # Make sure eval "$(brew shellenv)" is called before sourcing oh-my-zsh.sh
    # See https://docs.brew.sh/Shell-Completion
    # initExtraBeforeCompInit = lib.strings.concatLines [
    #   (homebrew "zsh") # only works in interactive shell
    # ];
    (homebrew shell)
    (preferNixOverBrew shell)
    (orbstack shell)
  ];
  commonInteractive = shell: [];
in {
  programs.zsh = {
    # Instead, use zsh-autocompletion https://github.com/marlonrichert/zsh-autocomplete
    # enableCompletion = false;
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
    initExtra = lib.strings.concatLines (commonInteractive "zsh");
  };

  programs.fish = {
    loginShellInit = lib.strings.concatLines (commonLogin "fish");
    interactiveShellInit = lib.strings.concatLines (
      commonInteractive "fish"
      ++ [
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
