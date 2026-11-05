# import & decrypt secrets in `my-secrets` in this module
{
  config,
  agenix,
  my-secrets,
  lib,
  pkgs,
  ...
}: let
  userSshDir = "${config.home.homeDirectory}/.ssh";

  mkSshSecret = name: file: {
    age.secrets.${name} = {
      file = "${my-secrets}/${name}.age";
      mode = "0400";
      symlink = true;
    };

    # Store only a symlink to the runtime secret, never its decrypted contents.
    home.file.".ssh/${file}".source =
      config.lib.file.mkOutOfStoreSymlink config.age.secrets.${name}.path;
  };
in {
  # agenix module
  imports = [
    agenix.homeManagerModules.default
    # SSH config file for bastions and servers
    (mkSshSecret "ssh_config_work" "config.d/ssh_config_work")
    # SSH key for bastions, servers and GitLab
    (mkSshSecret "id_rsa_em" "id_rsa_em")
    (mkSshSecret "id_ed25519_em" "id_ed25519_em")
  ];

  # Keep a stable symlink address; plaintext stays in agenix's default runtime mountpoint.
  age.secretsDir = "${config.home.homeDirectory}/.agenix";

  launchd.agents.activate-agenix = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    config = {
      KeepAlive = {
        # https://github.com/ryantm/agenix/issues/308
        Crashed = lib.mkForce null;
      };
    };
  };

  # Create new SSH directories privately; leave permissions of existing directories alone.
  home.activation.prepareSshSecretDirs = lib.hm.dag.entryBetween ["linkGeneration"] ["writeBoundary"] ''
    (
      umask 077
      run mkdir -p -- ${lib.escapeShellArg "${userSshDir}/config.d"}
    )
  '';
}
