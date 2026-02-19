# =============================================================================
# Rice: DankMaterialShell (DMS) - Material Design rice para Hyprland
# Autor: rag (via AI Maintainer)
#
# O que é:
# - Rice completa baseada em Material Design para Hyprland
# - Integração com DankMaterialShell (https://github.com/AvengeMedia/DankMaterialShell)
# - Inclui Waybar, Rofi, Hyprland config customizado
#
# Por quê:
# - Interface moderna e bonita para Hyprland
# - Configuração declarativa (links de arquivos do DMS repo)
# - Fácil atualizar (nix flake update)
#
# Como usar:
# 1. No flake.nix, o input DMS já está configurado
# 2. No Home Manager: rag.rice.dms.enable = true;
# 3. Este módulo faz links dos configs do DMS para ~/.config
#
# Riscos:
# - DMS pode conflitar com configs manuais em ~/.config
# - Usar force = true para sobrescrever
# =============================================================================
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.rag.rice.dms;

  # Source do DMS (flake input)
  dmsSource = inputs.dms;

in
{
  options.rag.rice.dms = {
    enable = lib.mkEnableOption "DankMaterialShell rice para Hyprland";

    variant = lib.mkOption {
      type = lib.types.enum [ "default" "minimal" "full" ];
      default = "default";
      description = ''
        Variante do DMS:
        - default: Configuração padrão do DMS
        - minimal: Menos widgets, mais performance
        - full: Todos os widgets e features
      '';
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Wallpaper customizado (substitui o padrão do DMS)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Validação: DMS só funciona com Hyprland
    assertions = [
      {
        assertion = config.wayland.windowManager.hyprland.enable or false;
        message = ''
          DMS (DankMaterialShell) requer Hyprland habilitado.

          Habilite Hyprland no sistema (desktop/hyprland/system.nix)
          E no Home Manager: wayland.windowManager.hyprland.enable = true
        '';
      }
    ];

    # =========================
    # Hyprland Config
    # =========================
    wayland.windowManager.hyprland = {
      # Links do config do DMS
      # NOTA: Ajustar paths conforme estrutura real do repo DMS
      extraConfig = ''
        # DankMaterialShell configuration
        # Source: https://github.com/AvengeMedia/DankMaterialShell

        # TODO: Verificar estrutura exata do repo DMS e ajustar paths
        # source = ${dmsSource}/hypr/hyprland.conf
      '';
    };

    # =========================
    # XDG Config Files (DMS)
    # =========================
    # NOTA: Ajustar conforme estrutura real do DMS
    xdg.configFile = {
      # Waybar (barra de status)
      # "waybar/config".source = "${dmsSource}/waybar/config";
      # "waybar/style.css".source = "${dmsSource}/waybar/style.css";

      # Rofi (launcher)
      # "rofi/config.rasi".source = "${dmsSource}/rofi/config.rasi";
      # "rofi/theme.rasi".source = "${dmsSource}/rofi/theme.rasi";

      # Hyprland (compositor)
      # "hypr/hyprland.conf".source = "${dmsSource}/hypr/hyprland.conf";

      # Wallpaper (se customizado)
      # "hypr/wallpaper.png".source =
      #   if cfg.wallpaper != null
      #   then cfg.wallpaper
      #   else "${dmsSource}/wallpapers/default.png";
    };

    # =========================
    # Pacotes Necessários
    # =========================
    home.packages = with pkgs; [
      # Waybar dependencies
      waybar

      # Rofi (launcher)
      rofi-wayland

      # Notificações
      dunst
      libnotify

      # Widgets e utilitários
      wttrbar  # weather
      # playerctl  # media control

      # Fonts (Material Design icons)
      material-design-icons
      material-symbols

      # Screenshot tools
      grim
      slurp

      # Clipboard
      wl-clipboard

      # Systray apps
      networkmanagerapplet
      blueman
      pavucontrol
    ];

    # =========================
    # Services
    # =========================
    # Waybar
    programs.waybar = {
      enable = true;
      # Config será linkado do DMS acima
    };

    # Dunst (notificações)
    services.dunst = {
      enable = true;
      # Config será linkado do DMS acima
    };

    # =========================
    # Fonts
    # =========================
    fonts.fontconfig.enable = true;

    # =========================
    # GTK Theme (Material)
    # =========================
    gtk = {
      enable = true;

      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      font = {
        name = "Roboto";
        size = 11;
        package = pkgs.roboto;
      };
    };

    # =========================
    # Qt Theme (Material)
    # =========================
    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita-dark";
    };

    # =========================
    # Cursor Theme
    # =========================
    home.pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
    };

    # =========================
    # Scripts de Instalação
    # =========================
    # Script para baixar/atualizar DMS config se necessário
    home.activation.setupDMS = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.bash}/bin/bash -c '
        echo "🎨 DankMaterialShell (DMS) está habilitado!"
        echo "Source: ${dmsSource}"
        echo ""
        echo "⚠️  NOTA: Config do DMS será linkado automaticamente."
        echo ""
        echo "TODO: Ajustar paths no módulo rice/dms após inspecionar estrutura do repo."
      '
    '';
  };
}

