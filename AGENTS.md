# AGENTS.md

Guide for agents working in this NixOS flake repository (`/home/erkkoi/nixos`).

## Repository Layout

- `flake.nix` / `flake.lock` — Flake entry point (`x86_64-linux`).
  - `nixpkgs` (`nixos-26.05`) backs `pannu` and the default devShell.
  - `nixpkgs-unstable` backs `torni`.
  - Other inputs: `disko`, `nix-minecraft`.
- `hosts/common.nix` — Shared config for all hosts: flakes enabled, `auto-optimise-store`, user `erkkoi` (`wheel`), `security.sudo.execWheelOnly`, weekly Btrfs scrub, `system.stateVersion = "26.05"`.
- `hosts/pannu/` — Public QEMU VPS (`nixos-26.05`, UTC):
  - `default.nix` — `system.autoUpgrade` from `github:erkkoi/nixos#pannu` (daily `03:00` UTC, `allowReboot = true` in `01:00–05:00`), SSH key-only auth (`erkkoi`, no UNIX password, passwordless `sudo`), `nix.settings.max-jobs = 1`, `zswap`.
  - `caddy.nix`, `opencloud.nix`, `minecraft.nix` — Hosted services.
  - `wireguard.nix` — WireGuard hub (`wg0`, `10.100.0.1/24`, UDP `51820`), `nftables` forwarding restricted strictly to `iPhone (10.100.0.3) -> torni (10.100.0.2):3773`.
  - `disk-config.nix` — Disko layout.
- `hosts/torni/` — Personal desktop workstation (`nixos-unstable`, `Europe/Helsinki`):
  - `default.nix` — Plasma 6, NVIDIA (`legacy_580`), Steam, hardened Firefox policies, password-required `sudo`, `antigravity-cli`, manual rebuilds.
  - `t3code-nightly.nix` / `t3code-nightly.svg` — Enables `programs.appimage` (`binfmt = true`) and provides a declarative `t3code-nightly` launcher + desktop entry that bootstraps the official nightly AppImage into `~/.local/share/t3code-nightly/` on first run (verifying SHA-512 from `nightly-linux.yml`) and relies on in-app auto-updates afterward. Set `T3CODE_FORCE_DOWNLOAD=1` to force a fresh download.
  - `wireguard.nix` — WireGuard peer (`10.100.0.2/24`, unmanaged by NetworkManager) allowing TCP `3773` only from `10.100.0.3`.
  - `disk-config.nix`, `hardware-configuration.nix` — Disko and hardware config.
- `pkgs/modpack/` — Packwiz-managed Fabric modpack (`pack.toml`, `index.toml`, `mods/*.pw.toml`) consumed by `pannu`'s Minecraft server; `default.nix` links only server-compatible mods (`side != "client"`).
- `.github/workflows/update_flake.yml` — Daily `01:00` UTC workflow that runs `nix flake update`, evaluates both hosts, and commits `flake.lock` only to `main`.

## Commands & Verification

- **New files and flakes:** Nix flakes only see Git-tracked files. Run `git add -N <path>` before evaluating or building newly created files.
- **Evaluate both hosts** (matches CI; run after any Nix edit):
  ```bash
  nix eval .#nixosConfigurations.pannu.config.system.build.toplevel.drvPath
  nix eval .#nixosConfigurations.torni.config.system.build.toplevel.drvPath
  ```
- **Format Nix files** (devShell includes `nixfmt`, `nixd`, `helix`, `packwiz`):
  ```bash
  nix develop -c nixfmt <files>
  ```
- **Apply locally on `torni`:**
  ```bash
  sudo nixos-rebuild switch --flake .#torni
  ```
- **Available CLI tools on `torni`:** Standard NixOS minimal PATH (e.g. `rg`, `jq`, `python3` are not globally installed — use `git grep`, `gh api --jq`, or `nix shell` / `nix develop` when needed).

## Conventions & Guardrails

- **`main` deploys to `pannu` automatically:** Changes merged to `main` are picked up by `pannu`'s `system.autoUpgrade`. Always verify `pannu` evaluates cleanly and keep resource constraints (`max-jobs = 1`, limited RAM) in mind.
- **No secrets in Git or the Nix store:** Runtime secrets belong under `/var/lib/secrets` (e.g. WireGuard keypairs generated on first boot by `wireguard-bootstrap-key`).
- **Keep CI minimal and pinned:** Pin GitHub Actions to full commit SHAs with version comments. Keep `.github/workflows/update_flake.yml` restricted to updating `flake.lock` only.
- **Firewall & unfree policy:** Both hosts use `networking.nftables.enable = true` with least-privilege rules. Keep `pannu`'s `nixpkgs.config.allowUnfreePredicate` narrowly scoped (`"minecraft-server"` only); `torni` allows unfree globally.
- **Host-specific `sudo`:** `torni` requires a password for `sudo`; only `pannu` keeps `wheelNeedsPassword = false` (SSH key-only, no UNIX password).
