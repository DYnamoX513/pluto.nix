# Pluto's Nix Config (Flakes)

> [!WARNING]
> Currently Nixpkgs-unstable is really UNSTABLE, or at least less stable than homebrew, on Darwin.
>
> 2025-03-13: nix-darwin - `config.system.stateVersion` has been safely updated from 5 to 6.
>
> 2025-09-18: `ragenix` is replaced by `agenix`:
> [ragenix does not build on Darwin 25.05 #159](https://github.com/yaxitech/ragenix/issues/159).


> [!NOTE]
> neovim-0.10.3 freezes [#368247](https://github.com/NixOS/nixpkgs/issues/368247) in some
> circumstances while neovim from Homebrew does not.
> This issue seems to be caused by a bug in tree-sitter 0.24.4, that is fixed in 0.24.5.
> Now it's fixed by [#368952](https://github.com/NixOS/nixpkgs/pull/368952).
> - [ ] We may update the flake inputs once the update is merged into the unstable channel
> and backported to the 24.11 stable channel.
>
> Check out [NixOS Status](https://status.nixos.org)

> [!NOTE]
> 2025-11-02: `clang-tools` (notably `clangd`) is broken in nixpkgs-unstable after the
> 2025-11-02 `staging-next` merge: [#463367](https://github.com/NixOS/nixpkgs/issues/463367).
> Workaround: pin `nixos-25.05` as an extra nixpkgs input and use `llvmPackages_21.clang-tools`.

---

## Deployment

### Prerequisites

**Install Nix**

For MacOS, please refer to [nix-darwin prerequisites](https://github.com/LnL7/nix-darwin#prerequisites).

E.g, [Determinate nix-installer](https://github.com/DeterminateSystems/nix-installer) (not Determinate Nix!)
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
# remember to remove the --determinate flag and enter 'no' when prompted  to use vanilla upstream Nix
```

**Use this flake**

```bash
# Clone this repository to your home directory
git clone https://github.com/DYnamoX513/pluto.nix.git ~/pluto.nix && cd ~/pluto.nix

# It's strongly recommended to use just to simplify the deployment process
nix-shell -p just
# or install through homebrew if on MacOS
# brew install just

# Both darwin-rebuild and nixos-rebuild use hostname to find the corresponding output by default.
# You need to set the variable _HOSTNAME_JUST_ in .justenv so that it can be picked up by just and passed to
# darwin-rebuild/nixos-rebuild.
just detect-env # set _HOSTNAME_JUST_ to current hostname
just show-env
```

### MacOS(Darwin)

```bash
# just install # first run (darwin-rebuild is not in PATH)
just darwin #
```

Since [`stateVersion >= 6`](https://daiderd.com/nix-darwin/manual/index.html#opt-environment.darwinConfig),
you can make a symbolic link to the flake repository in `/etc/nix-darwin`. Then you can run
`darwin-rebuild switch` from anywhere instead of `darwin-rebuild <cmd> --flake <path-to-flake>`.

**Further readings**

- [Is nix-darwin installing a second Nix? #931](https://github.com/LnL7/nix-darwin/issues/931)

### NixOS

```bash
just nixos
```

After a successful build, you can bootstrap the system config:

```bash
sudo mv /etc/nixos /etc/nixos~
sudo ln -s /path/to/flake /etc/nixos

nixos-rebuild switch
```

## TODO

- [x] Secret management: ssh config, ssh-key, OATH (TOTP)key, etc.
- [ ] Alacritty: Another terminal emulator written in Rust
- [x] Clean up programs installed by both Homebrew (preferred) and home-manager
- [ ] Miscellaneous files: .clang-tidy, .clang-format, harper-ls's dictionary, etc.
- [x] Maybe NixOS~~/RHEL Linux w. Nix~~ in OrbStack?

## Credits

This flake is inspired by [Nix Darwin Kick-starter](https://github.com/ryan4yin/nix-darwin-kickstarter),
[ryan4yin nix-config](https://github.com/ryan4yin/nix-config)
