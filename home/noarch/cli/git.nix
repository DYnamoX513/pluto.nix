{
  userfullname,
  useremail,
  ...
}: {
  # Home Manager writes Git configuration to $XDG_CONFIG_HOME/git/config.
  # Git also reads ~/.gitconfig afterwards, so its settings can override these.
  # Preserve existing user configuration; migrate conflicting settings manually.
  # https://git-scm.com/docs/git-config#Documentation/git-config.txt---global

  programs.git = {
    enable = true;
    lfs.enable = true;

    # includes = [
    #   {
    #     # use diffrent email & name for work
    #     path = "~/work/.gitconfig";
    #     condition = "gitdir:~/work/";
    #   }
    # ];

    signing.format = null;

    settings = {
      user = {
        name = userfullname;
        email = useremail;
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      # pull.rebase = true;

      alias = {
        # common aliases
        br = "branch";
        co = "checkout";
        st = "status";
        ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
        ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        amend = "commit --amend -m";

        # aliases for submodule
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      diff-so-fancy = true;
      line-numbers = true;
      true-color = "always";
    };
  };
}
