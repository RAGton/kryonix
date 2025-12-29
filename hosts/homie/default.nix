{ config, lib, pkgs, self, ... }:

{
  boot.loader.systemd-boot.enable = true;

  this = {
    home = ./../../home;

    user = {
      enable = true;
      me = {
        name = "rag";
        repo = "git@github.com:ragton/dotfiles.git";
        dotfilesDir = "/home/rag/dotfiles";
        extraGroups = [ "wheel" "networkmanager" ];
      };
      i18n = "pt_BR.UTF-8";
    };

    host = {
      system = "x86_64-linux";
      hostname = "inspiron";
      interface = [ "wlo1" ];

      modules = {
        hardware = [ "cpu/intel" "audio" ];
        system = [ "nix" "pkgs" ];
        networking = [ "default" ];
        services = [ "default" ];
        programs = [ "default" ];
      };
    };
  };

  imports = [
    ./disks.nix
  ];

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
