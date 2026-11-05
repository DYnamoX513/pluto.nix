# Repository guidance

## Wiring

- `flake.nix` builds hosts through `mkDarwinConfig`/`mkNixosConfig`, integrating Home Manager into system rebuilds; there are no standalone home configurations.
- Darwin targets: `Pluto-M3-Max` (`aarch64-darwin`) and `Pluto-i7-8750H` (`x86_64-darwin`). NixOS target: `Hydra-Orbiting` (`aarch64-linux`), exported by `hosts/Pluto-M3-Max/default.nix`.
- `scanPaths` automatically imports immediate directories and `.nix` files except `default.nix`; adding files to scanned module directories activates them.
- Home modules are selected in `home/collect-home-modules.nix`. Hydra disables GUI and secrets and imports only `modules/linux/environment.nix`, not all of `modules/linux`.

## Commands

- Run rebuild recipes from the repository root. `just show-env` displays the ignored `.justenv`; `_HOSTNAME_JUST_` selects the flake target. `just detect-env` overwrites it with the local hostname, which must match an exported target.
- `just build` builds without activation using the platform's rebuild tool; `just nh-build` is the alternative. No test suite, CI workflow, or flake `checks` output is defined.
- `just fmt` formats the whole repository with Alejandra. For focused formatting, use `alejandra path/to/file.nix`.
- `just darwin`, `just nixos`, and `just nh-switch` activate system changes; do not use them merely to validate. `just install` bootstraps Darwin and also activates.
- `just upp <input>` updates one locked input; `just up` updates all inputs.

## Package policy

- On macOS, prefer Homebrew for new packages (formulae or casks), with Home Manager managing configuration and shell integration rather than installing the package through Nix. This keeps package updates independent of system rebuilds.
- Add shared Homebrew packages in `modules/darwin/brew.nix`, or host-specific packages in the host's `homebrew` configuration.
- `brewery` reads system Homebrew lists; use the existing `isFormula`/`isCask` pattern in Home Manager modules to avoid duplicate Nix installations while preserving configuration and shell integration.

## Gotchas

- Flake resolution may require SSH access to the private `my-secrets` input, even when the selected host disables secret modules.
- SSH work-secret links are managed by Home Manager through `mkOutOfStoreSymlink` to agenix's runtime paths. Keep plaintext and identity contents out of Nix expressions/store inputs, do not use `force` to bypass private-key collisions, and do not decrypt secrets or activate their agent merely to validate configuration changes.
- Darwin requires an existing Homebrew installation.
- `hosts/Pluto-M3-Max/brew-only.nix` is not imported; the active package-selection mechanism is `home/noarch/brewery.nix`.
- Neovim, Helix, and WezTerm Lua configs use live out-of-store symlinks under the Home Manager `dotfilesRoot` option (default: `${home.homeDirectory}/pluto.nix`). Override it with an absolute string in a host's home modules to select another checkout; relocation or a worktree does not automatically retarget links.
- `share/nvim` is a separate Git submodule, not ordinary parent-repository content.
- `hosts/Pluto-M3-Max/Hydra-Orbiting/orbstack.nix` is a vendored snapshot of OrbStack-generated integration, not automatically synchronized with OrbStack updates. Keep local customizations in `configuration.nix`; hostname is managed there, without a separate `incus.nix`. Snapshot provenance and refresh guidance are in README.
- Hydra's `/etc/nixos` currently points to `/home/pluto/pluto.nix`. External writes through that path can reach the checkout; inspect Git changes after OrbStack updates. Do not change the guest directory layout or regenerate files into the checkout merely to validate a change.
- State versions are compatibility settings, not dependency versions: Darwin `6`, Home Manager/NixOS `24.11`. Do not bump them as part of an input update.
