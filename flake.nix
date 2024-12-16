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
    # substituers will be appended to the default substituters when fetching packages
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      # the default public key of cache.nixos.org, it's built-in, no need to add it here
      # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's unstable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # for macos
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
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

  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ {
    self,
    nixpkgs,
        nixpkgs-darwin,
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

    username = import ./check-user.nix { username = "pluto"; };
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
    }: nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/system.nix
        ./modules/nix-core.nix
        ./modules/brew.nix

      ] ++ extra-modules ++ [

        ({lib, ...}: {
          nixpkgs.pkgs = import nixpkgs-darwin {inherit system;};
        })
                        ]

      ++ (
        # home manager
        nixpkgs.lib.optionals ((nixpkgs.lib.lists.length home-modules) > 0)
        [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

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
     hosts = map (f: import (./hosts + "${f}")) builtins.attrNames( builtins.readDir ./hosts);
  in {
    # 动态生成 darwinConfigurations
    darwinConfigurations = nixpkgs.lib.attrsets.mergeAttrsList map (c: c.darwinConfiguration or {}) hosts;

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}

