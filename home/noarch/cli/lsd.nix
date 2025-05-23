{
  config,
  pkgs,
  lib,
  isFormula,
  ...
}: let
  settings = {
    color = {
      # When to colorize the output.
      # When "classic" is set, this is set to "never".
      # Possible values: never, auto, always
      when = "auto";
      # How to colorize the output.
      # When "classic" is set, this is set to "no-color".
      # Possible values: default, custom
      # When "custom" is set, lsd will look in the config directory for `colors.yaml`.
      theme = "custom";
    };
  };
  colors = {
    user = 110;
    group = 67;
    permission = {
      read = "dark_green";
      write = "dark_yellow";
      exec = "dark_red";
      exec-sticky = 5;
      no-access = 245;
      octal = 6;
      acl = "dark_cyan";
      context = "cyan";
    };
    date = {
      hour-old = 40;
      day-old = 42;
      older = 36;
    };
    size = {
      none = 218;
      small = 216;
      medium = 210;
      large = 172;
    };
    inode = {
      valid = 13;
      invalid = 245;
    };
    links = {
      valid = 13;
      invalid = 245;
    };
    tree-edge = 245;
    git-status = {
      default = 245;
      unmodified = 245;
      ignored = 245;
      new-in-index = "dark_green";
      new-in-workdir = "dark_green";
      typechange = "dark_yellow";
      deleted = "dark_red";
      renamed = "dark_green";
      modified = "dark_yellow";
      conflicted = "dark_red";
    };
  };

  brewed = isFormula "lsd";

  yamlFormat = pkgs.formats.yaml {};
  # aliases that use lsd in PATH
  aliases = {
    ls = "lsd";
    ll = "lsd -l";
    la = "lsd -A";
    lt = "lsd --tree";
    lla = "lsd -lA";
    llt = "lsd -l --tree";
  };
in
  lib.mkMerge [
    {
      # use nixpkgs-lsd only if it's not added to brew list
      programs.lsd.enable = !brewed;
    }
    (lib.mkIf (!brewed) {
      programs.lsd = {
        enableAliases = true;
        inherit settings colors;
      };
    })
    (lib.mkIf brewed {
      xdg.configFile."lsd/config.yaml".source = yamlFormat.generate "lsd-config" settings;
      xdg.configFile."lsd/colors.yaml".source = yamlFormat.generate "lsd-colors" colors;

      programs.zsh.shellAliases = aliases;
      programs.fish = with lib;
        mkMerge [
          (mkIf (!config.programs.fish.preferAbbrs) {shellAliases = aliases;})
          (mkIf config.programs.fish.preferAbbrs {shellAbbrs = aliases;})
        ];
    })
  ]
