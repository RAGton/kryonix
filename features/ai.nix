# =============================================================================
# Feature: AI tools (opcional)
#
# Objetivo:
# - Evitar builds lentos por padrão (ex.: Codex), mantendo ativação simples.
# - Tudo opt-in via `kryonix.features.ai.*`.
# =============================================================================
{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.kryonix.features.ai;
in
{
  options.kryonix.features.ai = {
    brain = {
      enable = lib.mkEnableOption "Kryonix Brain (LightRAG + Ollama)";
      role = lib.mkOption {
        type = lib.types.enum [ "server" "client" "standalone" ];
        default = "standalone";
        description = "Papel do host no ecossistema Brain.";
      };
      serverHost = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Endereço do servidor central.";
      };
      brainPort = lib.mkOption {
        type = lib.types.port;
        default = 8000;
      };
      ollamaPort = lib.mkOption {
        type = lib.types.port;
        default = 11434;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.codex.enable {
      environment.systemPackages = [
        inputs.codex.packages.${pkgs.system}.default
      ];
    })

    (lib.mkIf (cfg.brain.enable && cfg.brain.role == "client") {
      environment.variables = {
        OLLAMA_HOST = "http://${cfg.brain.serverHost}:${toString cfg.brain.ollamaPort}";
        KRYONIX_BRAIN_URL = "http://${cfg.brain.serverHost}:${toString cfg.brain.brainPort}";
        KRYONIX_VAULT_MODE = "remote-readonly";
      };

      environment.systemPackages = [
        (pkgs.writeShellScriptBin "kryonix-search" ''
          set -euo pipefail
          query="''${1:-}"
          if [ -z "$query" ]; then
            echo "Uso: kryonix-search \"pergunta\""
            exit 1
          fi
          ${pkgs.curl}/bin/curl -s -X POST "$KRYONIX_BRAIN_URL/search" \
            -H "Content-Type: application/json" \
            -d "{\"query\": \"$query\", \"lang\": \"pt-BR\"}" \
            | ${pkgs.jq}/bin/jq -r '.answer'
        '')

        (pkgs.writeShellScriptBin "kryonix-stats" ''
          ${pkgs.curl}/bin/curl -s "$KRYONIX_BRAIN_URL/stats" | ${pkgs.jq}/bin/jq .
        '')
        
        (pkgs.writeShellScriptBin "kryonix-brain-health" ''
          ${pkgs.curl}/bin/curl -s "$KRYONIX_BRAIN_URL/health" | ${pkgs.jq}/bin/jq .
        '')
      ];
    })
  ];
}
