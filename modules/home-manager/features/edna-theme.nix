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
      iconTheme = {
        name = lib.mkForce "Papirus-Dark";
        package = lib.mkForce pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = lib.mkForce "Bibata-Modern-Ice";
        package = lib.mkForce pkgs.bibata-cursors;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    # Instalação declarativa dos assets nos diretórios do usuário (~/.local/share, ~/.config, ~/.themes)
    # As declarações xdg.dataFile e home.file manuais foram removidas para evitar duplicidade.
    # O pacote `ednaAssets` adicionado em `home.packages` já as disponibiliza via XDG_DATA_DIRS.

    # Configuração NATIVA do KDE Plasma 6 ("Alternar para o modo escuro à noite")
    # Configura kdeglobals (ColorScheme/DarkColorScheme) via plasma-manager apenas se o script systemd NÃO for o responsável.
    programs.plasma.configFile = lib.mkIf (cfg.usePlasmaNative && !cfg.useSystemdTimer) {
      kdeglobals = {
        General = {
          ColorScheme = lib.mkForce "Edna-Light";
          DarkColorScheme = lib.mkForce "Edna";
          AccentColor = lib.mkForce "";
          accentColorFromWallpaper = lib.mkForce false;
        };
        DayNight = {
          Active = lib.mkForce true;
        };
      };
    };

    # Forçar Look And Feel, Color Scheme e Workspace via Plasma-Manager nativo
    programs.plasma.workspace = lib.mkMerge [
      {
        iconTheme = lib.mkForce "Papirus-Dark";
        cursor = {
          theme = lib.mkForce "Bibata-Modern-Ice";
          size = lib.mkForce 24;
        };
        wallpaper = lib.mkForce null;
      }
      (lib.mkIf (!cfg.useSystemdTimer) {
        theme = lib.mkForce (if cfg.defaultVariant == "light" then "Edna-Light" else "Edna");
        colorScheme = lib.mkForce (if cfg.defaultVariant == "light" then "Edna-Light" else "Edna");
        lookAndFeel = lib.mkForce (
          if cfg.defaultVariant == "light" then
            "com.github.PaulXFCE.Edna-Light"
          else
            "com.github.PaulXFCE.Edna"
        );
      })
    ];

    # (Removido: scripts de ativação home.activation.clearKdeCache e removeMutableKdeState)
    # A deleção agressiva desses caches e de kdeglobals em tempo real estava corrompendo a sessão Wayland
    # e impedindo programas de abrir. O Plasma-manager já gerencia o state.

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
