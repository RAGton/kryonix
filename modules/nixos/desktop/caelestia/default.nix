{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.rag.shell.caelestia;
  system = pkgs.stdenv.hostPlatform.system;
  caelestiaPackages = inputs.caelestia-shell.packages.${system};
  defaultPackage = caelestiaPackages.with-cli;
in
{
  options.rag.shell.caelestia = {
    enable = lib.mkEnableOption "Caelestia Shell como shell principal do stack Hyprland";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "inputs.caelestia-shell.packages.<system>.with-cli";
      description = ''
        Pacote do Caelestia instalado no sistema.

        O padrão usa o input `caelestia-shell` pinado no flake. Para testar o clone
        local em `/home/rocha/src/caelestia-shell` sem vazar esse path para outros
        hosts, prefira rebuilds com:

          --override-input caelestia-shell path:/home/rocha/src/caelestia-shell
      '';
    };

    systemdTarget = lib.mkOption {
      type = lib.types.str;
      default = "hyprland-session.target";
      description = "Target systemd-user responsável por iniciar o Caelestia na sessão gráfica.";
    };

    environment = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "QT_QPA_PLATFORM=wayland" ];
      description = "Variáveis extras exportadas para o serviço systemd-user do Caelestia.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.rag.desktop.environment == "hyprland";
        message = "rag.shell.caelestia.enable requer rag.desktop.environment = \"hyprland\".";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.user.services.caelestia = {
      description = "Caelestia Shell";
      after = [ cfg.systemdTarget ];
      partOf = [ cfg.systemdTarget ];
      wantedBy = [ cfg.systemdTarget ];

      serviceConfig = {
        Type = "exec";
        ExecStart = "${cfg.package}/bin/caelestia-shell";
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStopSec = "5s";
        Slice = "session.slice";
        Environment = cfg.environment;
      };
    };
  };
}
