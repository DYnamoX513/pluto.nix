{...}:
###################################################################################
#
#  System configuration
#
#  All the configuration options are documented here:
#    https://search.nixos.org/options
#
###################################################################################
{
  system = {
    # NixOS will option defaults corresponding to the specified release
    stateVersion = "24.11";
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  programs.fish.enable = true;
}
