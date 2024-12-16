{ username, scanPaths, ... }:

{
  # import sub modules
    imports = scanPaths ./.;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
    programs.fish = {
enable = true;
        functions = {
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
            java8 = {
body = ''
    set -gx JAVA_HOME (/usr/libexec/java_home -v 1.8)
    echo "JAVA_HOME set to $JAVA_HOME"
    java -version
                '';
            };
            unset_java = {
body = ''
    set -e JAVA_HOME
    echo "JAVA_HOME has been unset"
            '';
            };
        };
    };

    programs.fzf = {
        enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;
    };
    programs.zoxide = {
        enable = true;

    enableFishIntegration = true;
    enableZshIntegration = true;
    };
}
