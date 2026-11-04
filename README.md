# Pluto's Nix Config (Flakes)

> [!WARNING]
> Currently Nixpkgs-unstable is really UNSTABLE, or at least less stable than homebrew, on Darwin.
>
> 2025-03-13: nix-darwin - `config.system.stateVersion` has been safely updated from 5 to 6.
>
> 2025-09-18: `ragenix` is replaced by `agenix`:
> [ragenix does not build on Darwin 25.05 #159](https://github.com/yaxitech/ragenix/issues/159).

> [!NOTE]
> The old Neovim 0.10.3 freeze ([#368247](https://github.com/NixOS/nixpkgs/issues/368247))
> was resolved by the tree-sitter update in
> [#368952](https://github.com/NixOS/nixpkgs/pull/368952), merged on 2024-12-29.
> The current locked Nixpkgs no longer needs this workaround, so Nix Neovim is not
> disabled. macOS still prefers Homebrew Neovim; removing it from the Homebrew list
> enables the Nix fallback.

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
just build  # build without activation or sudo
just darwin # build and activate; prompts for sudo authentication
```

Run these recipes as your normal user. `just install`, `just darwin`, and
`just darwin-debug` invoke `sudo` for `darwin-rebuild switch`, because system
activation requires root. `just install` runs its initial `nix build` without sudo.

Since [`stateVersion >= 6`](https://daiderd.com/nix-darwin/manual/index.html#opt-environment.darwinConfig),
you can make a symbolic link to the flake repository in `/etc/nix-darwin`. Then you can run
`sudo darwin-rebuild switch` from anywhere instead of `darwin-rebuild <cmd> --flake <path-to-flake>`.

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

#### OrbStack configuration ownership

`Hydra-Orbiting` is an OrbStack Linux machine with a shared kernel, not an
independent VM. Its configuration lives in `hosts/Pluto-M3-Max/Hydra-Orbiting`:

- `default.nix`: flake host entry point and system/Home Manager module selection.
- `configuration.nix`: maintained host configuration, including hostname, user,
  networking, the host's OrbStack CA, and the existing `stateVersion = "24.11"`.
- `orbstack.nix`: vendored snapshot of OrbStack-generated integration. It is
  imported once by `configuration.nix`; keep local customizations out of it.

The former `incus.nix` contained only hostname configuration, which is now managed
in `configuration.nix`.

## Development shells

The legacy GCC 7 shell is exported only for `aarch64-linux`, for use inside
`Hydra-Orbiting` (the OrbStack NixOS guest on the M3 Mac):

```bash
# Run inside the NixOS guest, not on macOS
nix develop ~/pluto.nix#gcc7
gcc --version
exit
```

The compiler comes from the locked Nixpkgs 24.11 input; this shell does not
recreate the complete historical CI environment.

## TODO

- [x] Secret management: ssh config, ssh-key, OATH (TOTP)key, etc.
- [ ] Alacritty: Another terminal emulator written in Rust
- [x] Clean up programs installed by both Homebrew (preferred) and home-manager
- [ ] Miscellaneous files: .clang-tidy, .clang-format, harper-ls's dictionary, etc.
- [x] Maybe NixOS~~/RHEL Linux w. Nix~~ in OrbStack?

## Credits

This flake is inspired by [Nix Darwin Kick-starter](https://github.com/ryan4yin/nix-darwin-kickstarter),
[ryan4yin nix-config](https://github.com/ryan4yin/nix-config)
