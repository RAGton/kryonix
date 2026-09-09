{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kryonix.home.features.desktop;
in
{
  options.kryonix.home.features.desktop = {
    kdeShortcuts.enable = lib.mkEnableOption "KDE expert shortcuts";

    lockScreenTheme.enable = lib.mkEnableOption "Kryonix lock screen theme";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.kdeShortcuts.enable {
      # Shortcuts são configurados via plasma-manager no futuro;
      # placeholder seguro por enquanto.
    })

    (lib.mkIf cfg.lockScreenTheme.enable {
      # Tema SDDM é configurado em nível sistema (nixos/features/desktop).
    })
  ];
}
