# NixOS and nix-darwin Configurations for My Machines

This repository contains my NixOS and nix-darwin configurations, managed through [Nix Flakes](https://nixos.wiki/wiki/Flakes).

Language: [PT-BR](README.md) | English (this file)

It is structured to scale across multiple machines and users, leveraging [nixpkgs](https://github.com/NixOS/nixpkgs), [home-manager](https://github.com/nix-community/home-manager), [nix-darwin](https://github.com/LnL7/nix-darwin), and other community projects.

## Showcase

### Hyprland

![hyprland](./files/screenshots/hyprland.png)

### KDE

![kde](./files/screenshots/kde.png)

### macOS

![macos](./files/screenshots/mac.png)

## Structure

- `flake.nix`: single source of truth (inputs/outputs for NixOS, nix-darwin and Home Manager).
- `hosts/`: per-machine system configuration (e.g. `inspiron`).
- `home/`: per-user, per-host Home Manager entry points.
- `files/`: assets and misc files (scripts, wallpapers, screenshots, avatar, etc.).
- `modules/`: reusable modules split by responsibility:
  - `modules/nixos/`: Linux system modules.
  - `modules/darwin/`: macOS system modules.
  - `modules/home-manager/`: user-space modules.
- `overlays/`: custom overlays.
- `flake.lock`: pinned inputs for reproducibility.

## Usage

### Apply configurations (NixOS)

- System:

```sh
sudo nixos-rebuild switch --flake .#inspiron
```

- User (Home Manager):

```sh
home-manager switch --flake .#rag@inspiron
```

### Makefile shortcuts

The [Makefile](Makefile) provides common targets (it assumes your local hostname matches the flake output):

```sh
make nixos-rebuild
make home-manager-switch
make flake-check
make flake-update
```
