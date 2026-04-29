{
  inputs,
  hostname,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../glacier
  ];

  # Sobrescrever partes do glacier que não fazem sentido no live
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  fileSystems = lib.mkForce { }; # ISO gerencia isso
  swapDevices = lib.mkForce [ ];

  # Garantir Tailscale no live para teste de rede
  services.tailscale.enable = true;

  # Desabilitar persistência se houver, pois é Live
  # kryonix.persistence.enable = lib.mkForce false;

  # Branding e customização
  networking.hostName = "glacier-live";
}
