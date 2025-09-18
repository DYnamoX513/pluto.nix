{lib, ...}: let
  # cargo
  cargo = shell:
    if shell == "fish"
    then "fish_add_path -p $HOME/.cargo/bin" # prepend by default
    else ''
      if [[ -f "$HOME/.cargo/env" ]]; then
          . "$HOME/.cargo/env"
      fi
    '';

  # Neovim mason installed binaries
  mason = shell:
    if shell == "fish"
    then
      # -a = append, but $fish_user_path is prepended to $PATH
      # results in $fish_user_path -> [mason] -> $PATH
      "fish_add_path -a $HOME/.local/share/nvim/mason/bin"
    else
      # prepend
      "export PATH=$HOME/.local/share/nvim/mason/bin:$PATH";

  # cargo + mason language
  commonLogin = shell: [
    (cargo shell)
    (mason shell)
  ];
  commonInteractive = shell: [];
in {
  programs.zsh = {
    enable = true;
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
    plugins = [];
    profileExtra = lib.strings.concatLines (commonLogin "zsh");
    initContent = lib.strings.concatLines (commonInteractive "zsh");
  };

  programs.fish = {
    enable = true;
    preferAbbrs = false;
    loginShellInit = lib.strings.concatLines (commonLogin "fish");
    interactiveShellInit = lib.strings.concatLines (commonInteractive "fish");
  };
}
