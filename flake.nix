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
    # Sets the substituter list for this flake; extra-substituters would append instead.
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
      # "https://mirror.sjtu.edu.cn/nix-channels/store" # SJTUG provides binary cache for nix-darwin

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
    # Both branches have release gates: nixos-unstable targets NixOS,
    # while nixpkgs-unstable serves Nixpkgs users across platforms.

    # Official NixOS package source, using nixos's unstable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable-24_11.url = "github:nixos/nixpkgs/nixos-24.11";
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

      # `follows` aliases this dependency to the root flake's nixpkgs input.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      # url = "github:yaxitech/ragenix"; # Rust-agenix
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Last Intel Darwin release line: accept 26.05 fixes without following unstable.
    nixpkgs-intel-mac.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-darwin-intel-mac = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-intel-mac";
    };
    home-manager-intel-mac = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-intel-mac";
    };
    agenix-intel-mac = {
      # agenix has no matching release line; retain the currently verified revision.
      url = "github:ryantm/agenix/b027ee29d959fda4b60b57566d64c98a202e0feb";
      inputs.nixpkgs.follows = "nixpkgs-intel-mac";
      inputs.home-manager.follows = "home-manager-intel-mac";
      inputs.darwin.follows = "nix-darwin-intel-mac";
      inputs.systems.url = "github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e";
    };

    # my private secrets, it's a private repository, you need to replace it with your own.
    # use SSH to authenticate via ssh-agent/ssh-key
    my-secrets = {
      # url = "git+ssh://git@github.com/DYnamoX513/pluto.nix-secrets.git?shallow=1";
      url = "git+ssh://git@github.com/DYnamoX513/pluto.nix-secrets.git";
      flake = false;
    };
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # `self` references this flake, including its outputs and source metadata.
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable-24_11,
    ...
  }: let
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
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
        inherit username userfullname useremail mkDarwinConfig mkNixosConfig scanPaths;
      };

    commonConfig = {
      libFunction,
      homeManagerModule,
      input-overrides ? {},
    }: {
      system,
      hostname,
      config-modules ? [],
      home-modules ? [],
      # Maps extra Nixpkgs inputs (e.g. { stable = nixpkgs-stable-24_11; }) to pkgs-stable in specialArgs.
      extra-nixpkgs ? {},
    }: let
      specialArgsEx =
        specialArgs
        // input-overrides
        // {
          inherit hostname system;
        }
        // nixpkgs.lib.mapAttrs'
        (name: value:
          builtins.warn "Extra nixpkgs source: pkgs-${name} (${value.shortRev})" {
            name = "pkgs-${name}";
            value = import value {
              inherit system;
            };
          })
        extra-nixpkgs;
    in
      libFunction {
        inherit system;
        specialArgs = specialArgsEx;
        modules =
          [
            ./modules/nix-core.nix
          ]
          # platform-specific modules
          ++ config-modules
          ++ (
            nixpkgs.lib.optionals (home-modules != []) [
              homeManagerModule
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";
                  extraSpecialArgs = specialArgsEx;
                  users."${username}".imports = home-modules;
                };
              }
            ]
          );
      };

    mkDarwinConfig = {input-overrides ? {}, ...} @ args: let
      hostInputs = inputs // input-overrides;
    in
      commonConfig {
        libFunction = hostInputs.nix-darwin.lib.darwinSystem;
        homeManagerModule = hostInputs.home-manager.darwinModules.home-manager;
        inherit input-overrides;
      }
      (removeAttrs args ["input-overrides"]);

    mkNixosConfig = {input-overrides ? {}, ...} @ args: let
      hostInputs = inputs // input-overrides;
    in
      commonConfig {
        libFunction = hostInputs.nixpkgs.lib.nixosSystem;
        homeManagerModule = hostInputs.home-manager.nixosModules.home-manager;
        inherit input-overrides;
      }
      (removeAttrs args ["input-overrides"]);

    # scan for all directories and files end with .nix but not default.nix
    scanPaths = path:
      map
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

    # generates nixosConfigurations
    nixosConfigurations = nixpkgs.lib.attrsets.mergeAttrsList (map (c: c.nixosConfiguration or {}) hosts);

    # Legacy GCC 7 environment for the old CI/CD pipeline, used inside Hydra-Orbiting.
    devShells.aarch64-linux = let
      pkgs = nixpkgs-stable-24_11.legacyPackages.aarch64-linux;
    in {
      # Run inside the OrbStack NixOS guest: nix develop ~/pluto.nix#gcc7
      gcc7 = pkgs.mkShell {
        packages = with pkgs; [
          gcc7
          # cmake
          # gnumake
        ];

        # shellHook = ''fish -C "gcc --version"'';
      };
    };

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: let
      source =
        if system == "x86_64-darwin"
        then inputs.nixpkgs-intel-mac
        else nixpkgs;
    in
      source.legacyPackages.${system}.alejandra);
  };
}
