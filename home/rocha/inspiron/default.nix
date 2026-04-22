{ lib, pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager/common
    ../../../desktop/hyprland/shell-backend.nix
    ../../../desktop/hyprland/user.nix
    ../../../desktop/hyprland/rice/caelestia-config.nix
    ../../shared/dev-workstation.nix
    ../shared/vscode.nix
  ];

  rag.shell.backend = "caelestia";

  rag.shell.caelestia.settings = {
    appearance = {
      transparency = {
        enabled = true;
        base = 0.82;
        layers = 0.36;
      };
    };

    border = {
      rounding = 18;
      smoothing = 30;
      thickness = 8;
    };

    dashboard = {
      enabled = true;
      showMedia = false;
      showWeather = false;
    };

    general.apps = {
      terminal = [ "rag-terminal" ];
      explorer = [ "dolphin" ];
      audio = [ "pavucontrol" ];
    };

    launcher = {
      showOnHover = false;
      maxShown = 8;
      maxWallpapers = 9;
      favouriteApps = [
        "app.zen_browser.zen"
        "code"
        "com.gexperts.Tilix"
        "virt-manager"
        "org.kde.dolphin"
        "org.kde.filelight"
        "com.anydesk.Anydesk"
      ];
    };

    paths.wallpaperDir = "~/Pictures/Wallpapers";
    sidebar.enabled = true;
    utilities.enabled = true;
  };

  home.packages = with pkgs; [
    atlauncher
  ];

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    general {
      gaps_in = 3
      gaps_out = 6
      border_size = 2
    }

    decoration {
      rounding = 8
      active_opacity = 1.0
      inactive_opacity = 1.0

      blur {
        enabled = false
      }
    }

    animations {
      enabled = false
    }

    misc {
      vfr = true
    }
  '';

}
