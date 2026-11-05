<h1 align="center">♇ Pluto's Nix Config</h1>

<p align="center">Personal configurations for Pluto and its moons.</p>

<p align="center">
  <a href="https://nix.dev"><img src="https://img.shields.io/badge/Nix-Flakes-5277C3?style=flat-square&amp;logo=nixos&amp;logoColor=white" alt="Nix Flakes"></a>
  <a href="https://github.com/nix-darwin/nix-darwin"><img src="https://img.shields.io/badge/macOS-nix--darwin-000000?style=flat-square&amp;logo=apple&amp;logoColor=white" alt="macOS with nix-darwin"></a>
  <a href="https://nixos.org"><img src="https://img.shields.io/badge/NixOS-OrbStack-5277C3?style=flat-square&amp;logo=nixos&amp;logoColor=white" alt="NixOS on OrbStack"></a>
  <a href="https://github.com/nix-community/home-manager"><img src="https://img.shields.io/badge/Home_Manager-dotfiles-56949F?style=flat-square" alt="Home Manager dotfiles"></a>
</p>

## Overview

One flake for macOS and NixOS, with Home Manager integrated into system rebuilds.
On macOS, Homebrew handles most applications while Nix manages the system and
user configuration.

| Target           | Platform         | Environment                                   |
| ---------------- | ---------------- | --------------------------------------------- |
| `Pluto-M3-Max`   | `aarch64-darwin` | MacBook Pro, M3 Max                           |
| `Pluto-i7-8750H` | `x86_64-darwin`  | MacBook Pro, Intel                            |
| `Hydra-Orbiting` | `aarch64-linux`  | Headless OrbStack NixOS machine on the M3 Mac |

This is a personal configuration, not a drop-in installer. Adapt the user, hosts,
and private inputs before applying it to another machine.

## Getting started

Prerequisites:

- Upstream Nix with `nix-command` and `flakes` enabled; see the
  [nix-darwin prerequisites](https://github.com/nix-darwin/nix-darwin#prerequisites) for macOS.
- [Homebrew](https://brew.sh) on macOS, and [just](https://just.systems)
  (`brew install just` or `nix-shell -p just`).
- GitHub SSH access for the Neovim submodule and private `my-secrets` input.
  Macs also need a local agenix identity key matching the encrypted secrets.

```bash
git clone --recurse-submodules https://github.com/DYnamoX513/pluto.nix.git ~/pluto.nix
cd ~/pluto.nix

just detect-env # use only when the local hostname matches a target above
just show-env
just check
```

To choose a target explicitly, run e.g.
`just add-env _HOSTNAME_JUST_ Pluto-M3-Max`. Run rebuild commands from the repository root.

For the **first macOS activation**, run `just install`; it bootstraps nix-darwin
and activates the configuration, prompting for sudo authentication.
For an existing NixOS guest, use the build and activation commands below.

## Everyday commands

Prefer [nh](https://github.com/nix-community/nh) for everyday rebuilds: it provides
clearer build output, package diffs, and automatic privilege elevation. Run
`just nh-build` and `just nh-switch` as your normal user; native rebuild recipes
remain available as a fallback.

| Task                                    | Command                                                              |
| --------------------------------------- | -------------------------------------------------------------------- |
| Check formatting and evaluate all hosts | `just check`                                                         |
| Check only formatting / host evaluation | `just fmt-check` / `just eval-all`                                   |
| Build without activation                | `just nh-build` / `just build`                                       |
| Activate the selected host              | `just nh-switch` / `just darwin` (macOS) / `sudo just nixos` (NixOS) |
| Update one input / all inputs           | `just upp nixpkgs` / `just up`                                       |
| Format Nix files                        | `just fmt`                                                           |
| List available commands                 | `just`                                                               |

After updating inputs, check and build before activating. `just check` does not
need a selected hostname; it does not build systems or decrypt secrets, and it
refuses lock updates. New Nix files must be Git-tracked to enter the flake source.
Evaluation success is not a guarantee that building or activation will succeed.

To return to the previous system generation:

```bash
sudo darwin-rebuild rollback           # macOS
sudo nixos-rebuild switch --rollback   # NixOS
```

Keep the previous generation until the new one is verified; garbage collection
can remove rollback targets.

## Notes

- **Live dotfiles:** Neovim, Helix, and WezTerm Lua configurations follow the local
  checkout. If it moves, set Home Manager's `dotfilesRoot` to an absolute string;
  it defaults to `${home.homeDirectory}/pluto.nix`.
- **Rollback boundaries:** system rollback does not restore Homebrew versions or
  changes to live dotfiles. Do not bump `stateVersion` merely to update dependencies.
- **Legacy development:** run `nix develop ~/pluto.nix#gcc7` inside Hydra
  (`aarch64-linux` only). It provides GCC 7, not a complete historical CI environment.

<details>
<summary>Repository location and optional /etc links</summary>

Keep the working checkout at `~/pluto.nix` on each machine. Another stable path
is also valid, but update `dotfilesRoot` if it differs from the default.
The checkout does not need to live in `/etc`.

Optionally, link `flake.nix` into the conventional configuration directory so
native rebuild commands can find the repository from anywhere.

> Linking only the file leaves room for generated files outside the checkout.

```bash
# macOS
sudo mkdir -p /etc/nix-darwin
sudo ln -s "$HOME/pluto.nix/flake.nix" /etc/nix-darwin/flake.nix

# NixOS
sudo mkdir -p /etc/nixos
sudo ln -s "$HOME/pluto.nix/flake.nix" /etc/nixos/flake.nix
```

Then `sudo darwin-rebuild switch` or `sudo nixos-rebuild switch` can discover the
flake automatically, using the local hostname as the target.

</details>

<details>
<summary>Maintaining the OrbStack integration</summary>

Hydra uses OrbStack's shared kernel and runs on the M3 Mac.
[`orbstack.nix`](hosts/Pluto-M3-Max/Hydra-Orbiting/orbstack.nix)
is a vendored snapshot from the initial OrbStack image, not automatically synced
with OrbStack updates. Keep local changes in
[`configuration.nix`](hosts/Pluto-M3-Max/Hydra-Orbiting/configuration.nix).

</details>

## TODO

- [ ] Try Alacritty.
- [ ] Manage `.clang-tidy`, `.clang-format`, and the harper-ls dictionary.

<details>
<summary>Historical notes</summary>

- **2024-12-29:** the upstream tree-sitter fix for the Neovim 0.10.3 freeze was
  merged in [#368952](https://github.com/NixOS/nixpkgs/pull/368952).
  The current configuration no longer disables Nix Neovim; macOS prefers Homebrew.
- **2025-03-13:** Darwin `system.stateVersion` migrated from 5 to 6. This is a
  compatibility migration, not a step to repeat when updating dependencies.
- **2025-09-18:** ragenix was replaced with agenix after a
  [Darwin build issue](https://github.com/yaxitech/ragenix/issues/159).

</details>

## Credits

Inspired by [nix-darwin-kickstarter](https://github.com/ryan4yin/nix-darwin-kickstarter)
and [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config).
