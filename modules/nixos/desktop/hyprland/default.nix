# Módulo NixOS: Desktop Hyprland
# Autor: rag
#
# O que é
# - Habilita Hyprland (Wayland compositor) e integrações de sessão (GDM, portals, polkit, keyring).
# - Instala um conjunto de ferramentas comuns para uso diário no Hyprland.
#
# Por quê
# - Deixa o ambiente Wayland completo e consistente logo após `nixos-rebuild`.
# - Evita configurar manualmente serviços essenciais (portal/polkit/keyring).
#
# Como
# - Ativa GDM e atualiza ambiente DBus no login.
# - Configura `programs.hyprland` e pacotes auxiliares.
#
# Riscos
# - `xdg-desktop-portal-wlr` pode conflitar com outros portals dependendo do stack; validar em upgrades.
{ pkgs, ... }:
{
  # Display manager.
  services.displayManager.gdm.enable = true;

  # Mantém variáveis do ambiente exportadas para a sessão via DBus.
  services.xserver.updateDbusEnvironment = true;

  # Bluetooth.
  services.blueman.enable = true;

  # Hyprland.
  programs.hyprland = {
    enable = true;
    portalPackage = pkgs.xdg-desktop-portal-wlr;
    withUWSM = true;
  };

  # Segurança/integração da sessão.
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  security.pam.services = {
    hyprlock = { };
    gdm.enableGnomeKeyring = true;
  };

  # Pacotes auxiliares do stack Hyprland.
  environment.systemPackages = with pkgs; [
    file-roller # gerenciador de arquivos compactados
    gnome-calculator
    gnome-pomodoro
    gnome-text-editor
    loupe # visualizador de imagens
    nautilus # gerenciador de arquivos
    seahorse # gerenciador de keyring
    totem # player de vídeo

    brightnessctl
    grim
    grimblast
    hypridle
    hyprlock
    hyprpaper
    hyprpicker
    libnotify
    networkmanagerapplet
    pamixer
    pavucontrol
    slurp
    wf-recorder
    wlr-randr
    wlsunset
  ];
}
