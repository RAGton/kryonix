# =============================================================================
# Feature: OpenRGB
#
# O que é:
# - Controle declarativo do OpenRGB via módulo NixOS oficial.
#
# Por quê:
# - Mantém RGB/hardware fora do perfil base e liga a feature somente em hosts
#   que precisam dela.
# =============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.kryonix.features.openrgb;
  legacyCfg = config.kryonix.hardware.openrgb;
  openrgbPackage = pkgs.openrgb;
  enableOpenrgb = cfg.enable || legacyCfg.enable;
in
{
  options.kryonix.features.openrgb = {
    enable = lib.mkEnableOption "OpenRGB (serviço, CLI e regras udev)";

    package = lib.mkOption {
      type = lib.types.package;
      default = openrgbPackage;
      defaultText = lib.literalExpression "pkgs.openrgb";
      description = "Pacote OpenRGB usado pelo serviço, CLI e regras udev.";
    };
  };

  config = lib.mkIf enableOpenrgb {
    services.hardware.openrgb = {
      enable = true;
      package = cfg.package;
    };

    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
  };
}
