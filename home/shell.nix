{...}:
{

    programs.fish = {
enable = true;
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
