# just is a command runner, Justfile is very similar to Makefile, but simpler.

set dotenv-path := "./.justenv"
dotenv-path := justfile_directory() / ".justenv"
# set dotenv-required
set dotenv-load

# List all the just commands
default:
  @just --list

[macos]
_get-hostname: 
  scutil --get LocalHostName

[linux]
_get-hostname: 
  hostname

# Add or update environment variable in `.justenv` file
add-env key value:
    # INFO: currently only _HOSTNAME_JUST_ is used as hostname in `nix build`
    if [ ! -f {{dotenv-path}} ] || ! grep -q "^{{key}}=" -m 1 {{dotenv-path}}; then \
        echo "{{key}}={{value}}" >> {{dotenv-path}}; \
    else \
        sed -i '' "s/^{{key}}=.*/{{key}}={{value}}/" {{dotenv-path}}; \
    fi

# Set `.justenv` using the current environment
[confirm('Existing env entries will be overwritten. Continue?')]
detect-env: (add-env "_HOSTNAME_JUST_" `just _get-hostname`)
    @# just --quiet add-env "_HOSTNAME_JUST_" `just _get-hostname`

hostname := env_var_or_default("_HOSTNAME_JUST_", "")

############################################################################
#
#  Darwin related commands
#
############################################################################

# Set proxy for nix-daemon: `just set-proxy http://127.0.0.1:7890`
[macos]
[group('system')]
set-proxy proxy:
    sudo python3 ./darwin_set_proxy.py set --proxy {{proxy}}
    sleep 1

# Unset proxy for nix-daemon
[macos]
[group('system')]
unset-proxy:
    sudo python3 ./darwin_set_proxy.py unset
    sleep 1

# `nix build & darwin-rebuild switch`. Useful when darwin-rebuild is not installed
[macos]
[group('system')]
install:
  nix build .#darwinConfigurations.{{hostname}}.system \
    --extra-experimental-features 'nix-command flakes'
  ./result/sw/bin/darwin-rebuild switch --flake .#{{hostname}}

# `darwin-rebuild build`
[macos]
[group('system')]
build:
  darwin-rebuild build --flake .#{{hostname}}

# `darwin-rebuild switch`
[macos]
[group('system')]
darwin: # darwin-set-proxy
  darwin-rebuild switch --flake .#{{hostname}}

# `darwin-rebuild switch --show-trace --verbose`
[group('system')]
[macos]
darwin-debug: # darwin-set-proxy
  darwin-rebuild switch --flake .#{{hostname}} --show-trace --verbose

# `darwin-rebuild --list-generations`
[macos]
[group('system')]
generations:
  darwin-rebuild --list-generations

############################################################################
#
#  nix related commands
#
############################################################################

# Update all the flake inputs
[group('nix')]
up:
  nix flake update

# Update specific input: `just upp nixpkgs`
[group('nix')]
upp input:
  nix flake update {{input}}

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
  nix repl -f flake:nixpkgs

# Remove all generations older than 7 days
[group('nix')]
clean:
  @if [ "$(id -u)" -ne 0 ]; then echo "You(${USER}) may need to switch to root before executing this recipe"; fi
  @# On Darwin, sudo ... gives the following warning
  @# warning: $HOME ('/Users/pluto') is not owned by you, falling back to the one defined in the 'passwd' file ('/var/root')
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  # garbage collect all unused nix store entries(system-wide)
  sudo nix-collect-garbage --delete-older-than 7d
  # garbage collect all unused nix store entries(for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d

# Format the nix files in this repo
[group('nix')]
fmt:
  nix fmt {{justfile_directory()}}

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/
