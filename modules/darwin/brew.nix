{
  pkgs,
  agenix,
  ...
}: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    neovim
    git
    just # use Justfile to simplify nix-darwin's commands
    agenix.packages.${system}.default # agenix CLI
  ];

  # in global environment
  environment.variables = {
    # EDITOR = "nvim";
    EDITOR = "hx";
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # WARN: To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      # autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      # upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      # cleanup = "zap";
      extraFlags = ["--verbose"];
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # Xcode = 497799835;
      # Wechat = 836500024;
      # QQ = 451108668;
      # TecentMetting = 1484048379;
      CotEditor = 1024640650;
      Wipr2 = 1662217862; # Safari content blocker
      Bitwarden = 1352778147;
    };

    taps = [
      "homebrew/services"
    ];

    # `brew install`
    brews = [
      "btop" # resource monitor written in c++. (for a Rust alternative, use bottom)
      "cmake"
      "conan" # c++ package manager
      "dust" # du in Rust
      "fastfetch"
      "fd"
      "gcc"
      "git-lfs"
      "gnu-tar" # GNU-tar (default `tar` is BSD-tar)
      "lrzsz" # https://trzsz.github.io/ssh
      "neovim" # WARN: nixpkgs's neovim seems broken in some circumstances (0.10.3)
      "node" # also required by pyright, prettier ...
      "oath-toolkit" # oath cli
      "python3"
      "ripgrep"
      "trzsz-ssh" # Simple ssh client with trzsz
      "uv" # Python package installer and resolver, written in Rust

      # Can be enabled in home-mananger
      # "fish"
      "fzf"
      "helix"
      "just"
      "lazygit"
      "lsd" # ls Deluxe
      "rbenv"
      "starship"
      "thefuck"
      "yazi" # file browser in terminal
      "zoxide" # z
    ];

    # `brew install --cask`
    casks = [
      "iina" # video player
      "keycastr" # show keystroke visualiser
      "neovide" # neovim GUI
      "openinterminal" # for Finder
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      "stats" # beautiful system monitor
      # "vivaldi" # Vivaldi browser
      "wezterm@nightly" # need manually update through 'brew update wezterm@nightly'
      "ghostty"

      # fonts
      "font-ibm-plex-mono"
      "font-ibm-plex-sans"
      "font-ibm-plex-serif"
      "font-input"
      "font-iosevka"
      # "font-iosevka-slab"
      "font-iosevka-ss08" # PragmataPro flavor

      # nerd fonts
      # "font-blex-mono-nerd-font" # Based on IBM Plex
      "font-iosevka-term-nerd-font"
      # "font-iosevka-term-slab-nerd-font"
      "font-symbols-only-nerd-font"
    ];
  };
}
