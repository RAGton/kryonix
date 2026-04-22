{
  config,
  lib,
  ...
}:
let
  cfg = config.rag.shell.caelestia;
in
{
  options.rag.shell.caelestia = {
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = ''
        Configuração user-level do `~/.config/caelestia/shell.json`.

        Este módulo publica apenas dados de configuração do shell. A ativação
        principal do Caelestia continua sendo feita no NixOS.
      '';
    };

    tokens = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Conteúdo opcional de `~/.config/caelestia/shell-tokens.json`.";
    };
  };

  config = lib.mkIf ((config.rag.shell.backend or null) == "caelestia") {
    xdg.configFile = lib.mkMerge [
      (lib.mkIf (cfg.settings != { }) {
        "caelestia/shell.json".text = builtins.toJSON cfg.settings;
      })
      (lib.mkIf (cfg.tokens != { }) {
        "caelestia/shell-tokens.json".text = builtins.toJSON cfg.tokens;
      })
    ];
  };
}
