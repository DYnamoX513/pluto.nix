# Pluto's Nix Config (Flakes)

> [!WARNING]
> Currently Nixpkgs-unstable is really UNSTABLE, or at least less stable than homebrew, on Darwin.

> [!NOTE]
> neovim-0.10.3 freezes [#368247](https://github.com/NixOS/nixpkgs/issues/368247) in some
> circumstances while neovim from Homebrew does not.
> This issue seems to be caused by a bug in tree-sitter 0.24.4, that is fixed in 0.24.5.
> Now it's fixed by [#368952](https://github.com/NixOS/nixpkgs/pull/368952).
> - [ ] We may update the flake inputs once the update is merged into the unstable channel
> and backported to the 24.11 stable channel.
>
> Check out [NixOS Status](https://status.nixos.org)


---
## WIP...

Currently working on nix-darwin & home-manager  
Inspired by [Nix Darwin Kick-starter](https://github.com/ryan4yin/nix-darwin-kickstarter), 
[ryan4yin nix-config](https://github.com/ryan4yin/nix-config)

## TODO

- [x] Secret management: ssh config, ssh-key, OATH (TOTP)key, etc.
- [ ] Alacritty: Another terminal emulator written in Rust
- [x] Clean up programs installed by both Homebrew (preferred) and home-manager
- [ ] Miscellaneous files: .clang-tidy, .clang-format, harper-ls's dictionary, etc.
- [ ] Maybe NixOS/RHEL Linux w. Nix in OrbStack?

...

