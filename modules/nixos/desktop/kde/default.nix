# Módulo NixOS: Desktop KDE Plasma 6
# Autor: rag
#
# O que é
# - Habilita o stack do KDE Plasma 6 no nível do sistema (SDDM + Plasma).
# - Ajusta tema/cursor do SDDM e remove alguns pacotes padrão do Plasma.
#
# Por quê
# - Mantém a decisão “KDE como desktop” declarativa e reaproveitável entre hosts.
# - Evita instalar apps KDE redundantes quando você já usa alternativas (ex.: terminal/editor).
#
# Como
# - `services.displayManager.sddm` + `services.desktopManager.plasma6`.
# - `environment.plasma6.excludePackages` para enxugar o conjunto padrão.
#
# Riscos
# - Excluir pacotes pode remover funcionalidades esperadas por alguns fluxos; revisar após upgrades do Plasma.
{ pkgs, ... }:
let
  wallpaper = ../../../home-manager/misc/wallpaper/wallpaper.jpg;
in
{
  # Display manager + Plasma.
  services.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
    settings.Theme.CursorTheme = "Nordzy-cursors";
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = [
    pkgs.nordzy-cursor-theme
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${wallpaper};
      type=image
    '')
  ];

  # Enxuga o conjunto padrão do Plasma.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    baloo-widgets
    elisa
    ffmpegthumbs
    kate
    khelpcenter
    konsole
    krdp
    plasma-browser-integration
  ];

  # Desabilita autostarts redundantes.
  systemd.user.services = {
    "app-org.kde.discover.notifier@autostart".enable = false;
    "app-org.kde.kalendarac@autostart".enable = false;
  };
}
