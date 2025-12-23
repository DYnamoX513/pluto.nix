# just is a command runner, Justfile is very similar to Makefile, but simpler.

set dotenv-path := "./.justenv"

dotenv_file := justfile_directory() / ".justenv"

# set dotenv-required

set dotenv-load := true

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
    @tmp="$(mktemp)" && \
      if [ -f "{{ dotenv_file }}" ]; then \
        awk -v k="{{ key }}" -v v="{{ value }}" 'BEGIN{p=k"=";found=0} {if(index($0,p)==1){print p v;found=1}else{print}} END{if(!found) print p v}' "{{ dotenv_file }}" > "$tmp"; \
      else \
        printf '%s=%s\n' "{{ key }}" "{{ value }}" > "$tmp"; \
      fi && \
      mkdir -p "$(dirname "{{ dotenv_file }}")" && \
      mv "$tmp" "{{ dotenv_file }}"

# Print `.justenv` contents to stdout
show-env:
    @if [ -f {{ dotenv_file }} ]; then cat {{ dotenv_file }}; else echo "{{ dotenv_file }} does not exist"; fi

# Set `.justenv` using the current environment
[confirm('Existing _HOSTNAME_JUST_ will be updated. Continue?')]
detect-env: (add-env "_HOSTNAME_JUST_" `just _get-hostname`)
    @# just --quiet add-env "_HOSTNAME_JUST_" `just _get-hostname`

# 1.15.0 Deprecated alias for env(key, default)
# hostname := env_var_or_default("_HOSTNAME_JUST_", "")

hostname := env("_HOSTNAME_JUST_", "")

_require-hostname:
    @if [ -z "{{ hostname }}" ]; then \
        echo "ERROR: hostname is empty. Run: just detect-env (or export _HOSTNAME_JUST_)" >&2; \
        exit 1; \
    fi

############################################################################
#
#  Darwin related commands
#
############################################################################

# Set proxy for nix-daemon: `just set-proxy http://127.0.0.1:7890`
[group('system')]
[macos]
set-proxy proxy:
    sudo python3 ./darwin_set_proxy.py set --proxy {{ proxy }}
    sleep 1

# Unset proxy for nix-daemon
[group('system')]
[macos]
unset-proxy:
    sudo python3 ./darwin_set_proxy.py unset
    sleep 1

# `nix build & darwin-rebuild switch`. Useful when darwin-rebuild is not installed
[group('system')]
[macos]
install: _require-hostname
    nix build .#darwinConfigurations.{{ hostname }}.system \
      --extra-experimental-features 'nix-command flakes'
    ./result/sw/bin/darwin-rebuild switch --flake .#{{ hostname }}

# `darwin-rebuild build`
[group('system')]
[macos]
build: _require-hostname
    darwin-rebuild build --flake .#{{ hostname }}

# `darwin-rebuild switch`
[group('system')]
[macos]
darwin: _require-hostname
    darwin-rebuild switch --flake .#{{ hostname }}

# `darwin-rebuild switch --show-trace --verbose`
[group('system')]
[macos]
darwin-debug: _require-hostname
    darwin-rebuild switch --flake .#{{ hostname }} --show-trace --verbose

# `darwin-rebuild --list-generations`
[group('system')]
[macos]
generations:
    darwin-rebuild --list-generations

############################################################################
#
#  Linux related commands
#
############################################################################

# `nixos-rebuild build`
[group('system')]
[linux]
build: _require-hostname
    nixos-rebuild build --flake .#{{ hostname }}

# `nixos-rebuild switch`
[group('system')]
[linux]
nixos: _require-hostname
    nixos-rebuild switch --flake .#{{ hostname }}

# `nixos-rebuild switch --show-trace --verbose`
[group('system')]
[linux]
nixos-debug: _require-hostname
    nixos-rebuild switch --flake .#{{ hostname }} --show-trace --verbose

# `nixos-rebuild --list-generations`
[group('system')]
[linux]
generations:
    nixos-rebuild --list-generations

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
    nix flake update {{ input }}

# List all generations of the system profile
[group('nix')]
history:
    nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
    nix repl -f flake:nixpkgs

# Clean up old generations
[group('nix')]
clean older-than="7d":
    @if [ "$(id -u)" -ne 0 ]; then echo "You(${USER}) may need to switch to root before executing this recipe"; fi
    @# On Darwin, sudo ... gives the following warning
    @# warning: $HOME ('/Users/pluto') is not owned by you, falling back to the one defined in the 'passwd' file ('/var/root')
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than {{ older-than }}

# Garbage collect all unused nix store entries
[group('nix')]
gc older-than="7d":
    # garbage collect all unused nix store entries(system-wide)
    sudo nix-collect-garbage --delete-older-than {{ older-than }}
    # garbage collect all unused nix store entries(for the user - home-manager)
    # https://github.com/NixOS/nix/issues/8508
    nix-collect-garbage --delete-older-than {{ older-than }}

# Format the nix files in this repo
[group('nix')]
fmt:
    nix fmt {{ justfile_directory() }}

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
    ls -al /nix/var/nix/gcroots/auto/

############################################################################
#
#  Experimental nh commands
#
############################################################################

[group('nh')]
[macos]
nh-build: _require-hostname
    nh darwin build -H {{ hostname }} {{ justfile_directory() }}

[group('nh')]
[macos]
nh-switch: _require-hostname
    nh darwin switch -H {{ hostname }} {{ justfile_directory() }}

[group('nh')]
[linux]
nh-build: _require-hostname
    nh os build -H {{ hostname }} {{ justfile_directory() }}

[group('nh')]
[linux]
nh-switch: _require-hostname
    nh os switch -H {{ hostname }} {{ justfile_directory() }}
