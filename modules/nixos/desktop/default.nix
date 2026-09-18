{ config, lib, ... }:
let
  env = config.kryonix.desktop.environment;
in
{
  imports = [
    ./kde
    ./sddm
    ./wallpaper
  ];

  config = lib.mkIf (env == "kde") {
    kryonix.desktop.directLogin.enable = lib.mkForce false;

    services.displayManager.gdm.enable = lib.mkForce false;
    services.desktopManager.gnome.enable = lib.mkForce false;
    services.greetd.enable = lib.mkForce false;
  };
}
