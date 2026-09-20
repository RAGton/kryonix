# modules/home-manager/features/edna-theme.nix
#
# Módulo Home Manager declarativo para o ecossistema de temas Edna (Light e Dark).
# Configura UI (GTK, Qt, Kvantum), implanta arquivos de temas e cria os serviços/timers do Systemd
# para transição automatizada dia/noite.

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kryonix.home.features.ednaTheme;

  ednaPkgs = pkgs.callPackage ../../../packages/themes/edna { };
  ednaAssets = ednaPkgs.edna-assets;
  ednaSwitcher = ednaPkgs.edna-switcher;
in
{
  options.kryonix.home.features.ednaTheme = {
    enable = lib.mkEnableOption "Módulo de tema declarativo Edna (Light/Dark) com transição dia/noite";

    defaultVariant = lib.mkOption {
      type = lib.types.enum [
        "light"
        "dark"
        "auto"
      ];
      default = "auto";
      description = "Variante inicial do tema Edna (light, dark ou auto conforme o horário).";
    };

    dayTime = lib.mkOption {
      type = lib.types.str;
      default = "07:00";
      description = "Horário de acionamento do tema Edna Light no formato OnCalendar do Systemd ou horário de término da luz noturna (ex: 07:00).";
    };

    nightTime = lib.mkOption {
      type = lib.types.str;
      default = "19:00";
      description = "Horário de acionamento do tema Edna Dark no formato OnCalendar do Systemd ou horário de início da luz noturna (ex: 19:00).";
    };

    usePlasmaNative = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Ativa a funcionalidade nativa do KDE Plasma 6 de alternar para o modo escuro à noite (kdeglobals / NightColor).";
    };

    useSystemdTimer = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Ativa o serviço e timer do Systemd para alternância completa via script edna-switcher (Kvantum/Konsole/Aurorae/GTK).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Pacotes necessários no ambiente do usuário
    home.packages = [
      ednaAssets
      ednaSwitcher
    ];

    # Configuração Declarativa de UI (GTK e Qt/Kvantum)
    gtk = {
      enable = true;
      theme = {
        name = lib.mkForce (if cfg.defaultVariant == "light" then "Edna-Light" else "Edna");
        package = lib.mkForce ednaAssets;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    # Instalação declarativa dos assets nos diretórios do usuário (~/.local/share, ~/.config, ~/.themes)
    xdg.dataFile = {
      "plasma/look-and-feel/com.github.PaulXFCE.Edna".source =
        "${ednaAssets}/share/plasma/look-and-feel/com.github.PaulXFCE.Edna";
      "plasma/look-and-feel/com.github.PaulXFCE.Edna-Light".source =
        "${ednaAssets}/share/plasma/look-and-feel/com.github.PaulXFCE.Edna-Light";
      "color-schemes/Edna.colors".source = "${ednaAssets}/share/color-schemes/Edna.colors";
      "color-schemes/Edna-Light.colors".source = "${ednaAssets}/share/color-schemes/Edna-Light.colors";
      "Kvantum/Edna".source = "${ednaAssets}/share/Kvantum/Edna";
      "Kvantum/Edna-Light".source = "${ednaAssets}/share/Kvantum/Edna-Light";
      "themes/Edna".source = "${ednaAssets}/share/themes/Edna";
      "themes/Edna-Light".source = "${ednaAssets}/share/themes/Edna-Light";
      "konsole/Edna.colorscheme".source = "${ednaAssets}/share/konsole/Edna.colorscheme";
      "konsole/Edna-Light.colorscheme".source = "${ednaAssets}/share/konsole/Edna-Light.colorscheme";
      "konsole/Edna.profile".source = "${ednaAssets}/share/konsole/Edna.profile";
      "konsole/Edna-Light.profile".source = "${ednaAssets}/share/konsole/Edna-Light.profile";
      "aurorae/themes/Edna".source = "${ednaAssets}/share/aurorae/themes/Edna";
      "aurorae/themes/Edna-Light".source = "${ednaAssets}/share/aurorae/themes/Edna-Light";
      "wallpapers/Edna".source = "${ednaAssets}/share/wallpapers/Edna";
    };

    home.file = {
      ".themes/Edna".source = "${ednaAssets}/share/themes/Edna";
      ".themes/Edna-Light".source = "${ednaAssets}/share/themes/Edna-Light";
      ".config/Kvantum/Edna".source = "${ednaAssets}/share/Kvantum/Edna";
      ".config/Kvantum/Edna-Light".source = "${ednaAssets}/share/Kvantum/Edna-Light";
    };

    # Configuração NATIVA do KDE Plasma 6 ("Alternar para o modo escuro à noite")
    # Configura kdeglobals (ColorScheme/DarkColorScheme) via plasma-manager
    programs.plasma.configFile = lib.mkIf cfg.usePlasmaNative {
      kdeglobals = {
        General = {
          ColorScheme = lib.mkForce "Edna-Light";
          DarkColorScheme = lib.mkForce "Edna";
        };
        DayNight = {
          Active = lib.mkForce true;
        };
      };
    };

    # Automação via Systemd User Services e Timers
    systemd.user.services = lib.mkIf cfg.useSystemdTimer {
      edna-theme-light = {
        Unit = {
          Description = "Ativar Tema Edna Light (Dia)";
          Documentation = [ "man:edna-switcher(1)" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${ednaSwitcher}/bin/edna-switcher light";
          Environment = [
            "DISPLAY=:0"
            "WAYLAND_DISPLAY=wayland-0"
            "XDG_RUNTIME_DIR=/run/user/%U"
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
          ];
        };
      };

      edna-theme-dark = {
        Unit = {
          Description = "Ativar Tema Edna Dark (Noite)";
          Documentation = [ "man:edna-switcher(1)" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${ednaSwitcher}/bin/edna-switcher dark";
          Environment = [
            "DISPLAY=:0"
            "WAYLAND_DISPLAY=wayland-0"
            "XDG_RUNTIME_DIR=/run/user/%U"
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
          ];
        };
      };

      edna-theme-auto = {
        Unit = {
          Description = "Inicialização Automática do Tema Edna";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${ednaSwitcher}/bin/edna-switcher auto";
          Environment = [
            "DISPLAY=:0"
            "WAYLAND_DISPLAY=wayland-0"
            "XDG_RUNTIME_DIR=/run/user/%U"
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
          ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };

    systemd.user.timers = lib.mkIf cfg.useSystemdTimer {
      edna-theme-light = {
        Unit = {
          Description = "Timer Diurno do Tema Edna (${cfg.dayTime})";
        };
        Timer = {
          OnCalendar = "*-*-* ${cfg.dayTime}:00";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      edna-theme-dark = {
        Unit = {
          Description = "Timer Noturno do Tema Edna (${cfg.nightTime})";
        };
        Timer = {
          OnCalendar = "*-*-* ${cfg.nightTime}:00";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
