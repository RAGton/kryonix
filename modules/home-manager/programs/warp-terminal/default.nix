{
  config,
  lib,
  pkgs,
  ...
}:
let
  kryonixTerminal = pkgs.writeShellApplication {
    name = "kryonix-terminal";
    runtimeInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.warp-terminal
    ];
    text = ''
      set -euo pipefail

      # Warp Terminal é o terminal padrão.
      if command -v uwsm >/dev/null 2>&1; then
        exec uwsm app -- warp-terminal "$@"
      fi
      exec warp-terminal "$@"
    '';
  };

  ragTerminalCompat = pkgs.writeShellApplication {
    name = "rag-terminal";
    runtimeInputs = [ kryonixTerminal ];
    text = ''
      set -euo pipefail

      printf '%s\n' "rag-terminal is deprecated, use kryonix-terminal" >&2
      exec kryonix-terminal "$@"
    '';
  };
in
{
  config = lib.mkIf (!pkgs.stdenv.isDarwin) {
    home.packages = [
      pkgs.warp-terminal
      kryonixTerminal
      ragTerminalCompat
    ];

    home.sessionVariables.TERMINAL = "warp-terminal";

    # Ajustes leves:
    # - Desliga auto-indexação de codebase do Agent Mode (pode ser pesada)
    # - Desliga sync de settings para reduzir ruído na primeira inicialização
    home.activation.warp-terminal-performance-tweaks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      prefs_file="${config.xdg.configHome}/warp-terminal/user_preferences.json"
      if [ -f "$prefs_file" ]; then
        tmp="$(mktemp)"
        if ${pkgs.jq}/bin/jq -e . >/dev/null 2>&1 < "$prefs_file"; then
          ${pkgs.jq}/bin/jq '
            .prefs.AgentModeCodebaseContextAutoIndexing = "false" |
            .prefs.IsSettingsSyncEnabled = "false"
          ' "$prefs_file" > "$tmp" && mv "$tmp" "$prefs_file"
        else
          rm -f "$tmp"
        fi
      fi
    '';
  };
}
