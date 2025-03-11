{
  description = "[♇]Nix configurations for Pluto and its moons";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  # for more information, see:
  #     https://nixos-and-flakes.thiscute.world/nix-store/add-binary-cache-servers
  nixConfig = {
    # substituters will be appended to the default substituters when fetching packages
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store" # SJTUG provides binary cache for nix-darwin

      "https://cache.nixos.org"
    ];
    # trusted-public-keys = [
    # the default public key of cache.nixos.org, it's built-in, no need to add it here
    # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    # ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Discussions about the differences between nixos-unstable and nixpkgs-unstable:
    # 1. https://nixos.wiki/wiki/Nix_channels
    # 2. https://www.reddit.com/r/NixOS/comments/1f46b04/whats_the_difference_between_these_nixosunstable
    # In brief, nixos-unstable is gated by nixos tests and nixpkgs-unstable is not.

    # Official NixOS package source, using nixos's unstable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # for macos
    # nixpkgs-darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-24.11";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      # url = "github:ryantm/agenix";
      url = "github:yaxitech/ragenix"; # Rust-agenix
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my private secrets, it's a private repository, you need to replace it with your own.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    my-secrets = {
      url = "git+ssh://git@github.com/DYnamoX513/pluto.nix-secrets.git?shallow=1";
      flake = false;
    };
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    ...
  }: let
    # Supported systems for your flake packages, shell, etc.
    systems = [
      # "aarch64-linux"
      # "i686-linux"
      # "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    username = "pluto";
    userfullname = "Yuxin Duan";
    useremail = "yd2614@columbia.edu";

    specialArgs =
      inputs
      // {
        inherit username userfullname useremail mkDarwinConfig scanPaths;
      };
    mkDarwinConfig = {
      system,
      hostname,
      extra-modules ? [],
      home-modules ? [],
    }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = specialArgs // {inherit hostname system;};
        modules =
          [
            ./modules/broken-pkgs.nix
            ./modules/brew.nix
            ./modules/host-users.nix
            ./modules/nix-core.nix
            ./modules/system.nix
          ]
          ++ extra-modules
          ++ (
            # home manager
            nixpkgs.lib.optionals ((nixpkgs.lib.lists.length home-modules) > 0)
            [
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                # backup existing config files
                home-manager.backupFileExtension = "hm-backup";

                home-manager.extraSpecialArgs = specialArgs;
                home-manager.users."${username}".imports = home-modules;
              }
            ]
          );
      };
    # scan for all directories and files end with .nix but not default.nix
    scanPaths = path:
      builtins.map
      (f: (path + "/${f}"))
      (builtins.attrNames
        (nixpkgs.lib.attrsets.filterAttrs
          (
            path: _type:
              (_type == "directory") # include directories
              || (
                (path != "default.nix") # ignore default.nix
                && (nixpkgs.lib.strings.hasSuffix ".nix" path) # include .nix files
              )
          )
          (builtins.readDir path)));
    # import all defined hosts
    hosts = map (f: import f specialArgs) (scanPaths ./hosts);
  in {
    # generates darwinConfigurations
    darwinConfigurations = nixpkgs.lib.attrsets.mergeAttrsList (map (c: c.darwinConfiguration or {}) hosts);

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
