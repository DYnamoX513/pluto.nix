# import & decrypt secrets in `my-secrets` in this module
{
  config,
  agenix,
  my-secrets,
  lib,
  system,
  ...
}: let
  userReadable = {
    mode = "0400";
    # owner = config.home.username;
    # group = config.home.username;
  };
  userSshDir = "${config.home.homeDirectory}/.ssh";

  mkSshSecret = name: file: {
    age.secrets.${name} =
      {
        # whether secrets are linked to age.secrets.<name>.path
        symlink = true;
        # target path for decrypted file
        # path =
        # encrypted file path
        file = "${my-secrets}/${name}.age";
      }
      // userReadable;

    # home.file.${".ssh/" + file}.source = config.age.secrets.${name}.path;
  };

  updateSymLink = from: to: ''
    echo "${from} -> ${to}"
    if [ ! -L "${to}" ] || [ "$(readlink ${to})" != "${from}" ]; then
        run ln -sib $VERBOSE_ARG ${from} ${to}
    fi
  '';
in {
  # agenix module
  imports = [
    # agenix.darwinModules.default
    agenix.homeManagerModules.default
    # SSH config file for bastions and servers
    (mkSshSecret "ssh_config_work" "config.d/ssh_config_work")
    # SSH key for bastions, servers and GitLab
    (mkSshSecret "id_rsa_em" "id_rsa_em")
    (mkSshSecret "id_ed25519_em" "id_ed25519_em")
  ];

  # home.packages = [agenix.packages.${system}.default]; installed system wide

  # age.identityPaths = [];

  # See [HM: default age.secrets.<name>.path isn’t a path](https://github.com/ryantm/agenix/issues/300)
  # default is `$(getconf DARWIN_USER_TEMP_DIR)`, so it benefits from auto-cleanup when the system reboot
  age.secretsDir = "${config.home.homeDirectory}/.agenix";

  launchd.agents.activate-agenix = {
    config = {
      KeepAlive = {
        # https://github.com/ryantm/agenix/issues/308
        Crashed = lib.mkForce null;
      };
    };
  };

  home.activation.symlinkAgenix = lib.hm.dag.entryAfter ["writeBoundary"] (lib.strings.concatLines [
    "mkdir -p ${userSshDir}/config.d"
    (updateSymLink config.age.secrets.ssh_config_work.path "${userSshDir}/config.d/ssh_config_work")
    (updateSymLink config.age.secrets.id_rsa_em.path "${userSshDir}/id_rsa_em")
    (updateSymLink config.age.secrets.id_ed25519_em.path "${userSshDir}/id_ed25519_em")
  ]);
}
