{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ragos;
in
{
  options.programs.ragos = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Instala a CLI `ragos`, usada como fluxo operacional principal do RagOS VE.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../../../packages/ragos-cli.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../../../packages/ragos-cli.nix { }";
      description = "Pacote da CLI `ragos` exposto no PATH do sistema.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
