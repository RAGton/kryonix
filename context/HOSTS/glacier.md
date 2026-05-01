# Host `glacier`

- papel: workstation principal para virtualização e gaming
- desktop: Hyprland
- shell: Caelestia
- storage operacional: `/srv/ragenterprise`

## Restrições

- tratar como host já instalado
- não usar `disko`, `format-*`, `install-system` ou `hosts/glacier/disks.nix` em patch incremental

## Validação típica

- `nix build 'path:$PWD#nixosConfigurations.glacier.config.system.build.toplevel'`
- `nix build 'path:$PWD#homeConfigurations."rocha@glacier".activationPackage'`

## Features

- `kryonix.profiles.server-ai.enable = true`: base obrigatória de IA/servidor.
- `kryonix.features.workstation.enable = true`: Hyprland/Caelestia e apps gráficos.
- `kryonix.features.gaming.enable = true`: Steam/GameMode/MangoHud/Gamescope.
- `kryonix.features.gaming.lutris.enable = false`: Lutris fica opt-in para evitar `openldap-i686-linux`.
- `kryonix.features.openrgb.enable = true`: OpenRGB via `services.hardware.openrgb`.
