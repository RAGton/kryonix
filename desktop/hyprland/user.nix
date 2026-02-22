# =============================================================================
# Desktop: Hyprland (User-level)
# Autor: rag
#
# O que é:
# - Configuração do ambiente Hyprland do usuário (configs em ~/.config/hypr, serviços e tema).
# - Integra módulos auxiliares (gtk/qt/wallpaper/xdg, waybar, swaync, kanshi etc.).
#
# Por quê:
# - Mantém o setup Wayland consistente e reprodutível em máquinas novas.
# - Centraliza o "stack" do Hyprland no Home Manager.
#
# Como:
# - Importa módulos do repo via `nhModules`.
# - Publica arquivos de config do Hyprland via `xdg.configFile`.
#
# Riscos:
# - Alterações em portals/serviços podem impactar notificações/clipboard/idle/lock.
#
# Migração v2:
# - Movido de modules/home-manager/desktop/hyprland/default.nix (Phase 2.4)
# - User-level config separado de system-level (desktop/hyprland/system.nix)
# =============================================================================
{
  config,
  lib,
  pkgs,
  nhModules,
  ...
}:
{
  imports = [
    "${nhModules}/misc/gtk"
    "${nhModules}/misc/qt"
    "${nhModules}/misc/wallpaper"
    "${nhModules}/misc/xdg"
    "${nhModules}/programs/swappy"
    "${nhModules}/programs/wofi"
    "${nhModules}/services/cliphist"
    "${nhModules}/services/kanshi"
    "${nhModules}/services/swaync"
    "${nhModules}/services/waybar"
  ];

  # Tema de cursor consistente em todos os aplicativos.
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = config.gtk.cursorTheme.package;
    name = config.gtk.cursorTheme.name;
    size = 24;
  };

  # Hyprland via Home Manager (necessário para integração correta com systemd-user).
  # Mantemos o arquivo `desktop/hyprland/hyprland.conf` como fonte única de verdade.
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    # Reaproveita o config versionado no repo (sem exec-once de barra aqui).
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  # Publica a configuração do Hyprland a partir do store do Home Manager.
  xdg.configFile = {
    "hypr/hyprpaper.conf".text = ''
      splash = false
      preload = ${config.wallpaper}
      wallpaper = , ${config.wallpaper}
    '';

    "hypr/hypridle.conf".text = ''
      general {
        lock_cmd = pidof hyprlock || $HOME/.local/bin/dynamic-hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
      }
    '';
  };

  # Garante que os arquivos do DMS existam como arquivos graváveis.
  # O Hyprland faz `source` desses arquivos; se não existirem, podem gerar erros.
  # Importante: NÃO gerenciar via xdg.configFile/home.file, para não virar symlink read-only.
  home.activation.ensureHyprDmsSnippets = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/hypr/dms"

    for f in binds.conf colors.conf layout.conf windowrules.conf; do
      if [ ! -e "$HOME/.config/hypr/dms/$f" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/touch "$HOME/.config/hypr/dms/$f"
      fi
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod 0644 "$HOME/.config/hypr/dms/$f"
    done
  '';

  dconf.settings = {
    "org/blueman/general" = {
      "plugin-list" = lib.mkForce [ "!StatusNotifierItem" ];
    };

    "org/blueman/plugins/powermanager" = {
      "auto-power-on" = true;
    };

    "org/gnome/calculator" = {
      "accuracy" = 9;
      "angle-units" = "degrees";
      "base" = 10;
      "button-mode" = "basic";
      "number-format" = "automatic";
      "show-thousands" = false;
      "show-zeroes" = false;
      "source-currency" = "";
      "source-units" = "degree";
      "target-currency" = "";
      "target-units" = "radian";
      "window-maximized" = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = lib.mkForce "";
    };

    "org/gnome/nautilus/preferences" = {
      "default-folder-viewer" = "list-view";
      "migrated-gtk-settings" = true;
      "search-filter-time-type" = "last_modified";
      "search-view" = "list-view";
    };

    "org/gnome/nm-applet" = {
      "disable-connected-notifications" = true;
      "disable-vpn-notifications" = true;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      "show-hidden" = true;
    };

    "org/gtk/settings/file-chooser" = {
      "date-format" = "regular";
      "location-mode" = "path-bar";
      "show-hidden" = true;
      "show-size-column" = true;
      "show-type-column" = true;
      "sort-column" = "name";
      "sort-directories-first" = false;
      "sort-order" = "ascending";
      "type-format" = "category";
      "view-type" = "list";
    };
  };
}
