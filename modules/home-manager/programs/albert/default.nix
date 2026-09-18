# =============================================================================
# Autor: rag
#
# O que é:
# - Módulo Home Manager para instalar e configurar o `albert` (launcher) no Linux.
# - Define config via XDG e serviço systemd user para iniciar junto da sessão gráfica.
#
# Por quê:
# - Padroniza o launcher e comandos de sistema sem depender de configuração manual.
# - Mantém autostart declarativo e reproduzível.
#
# Como:
# - Ativa somente fora do Darwin via `lib.mkIf (!pkgs.stdenv.isDarwin)`.
# - Instala `pkgs.albert`, escreve `~/.config/albert/config` e cria `systemd.user.services.albert`.
#
# Riscos:
# - A string `command_logout` faz logout limpo no KDE Plasma via qdbus (org.kde.ksmserver).
# - Fallback: loginctl terminate-session.
# =============================================================================
{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (!pkgs.stdenv.isDarwin) {
    # Pacote do Albert.
    home.packages = [ pkgs.albert ];

    # Importa a configuração do Albert a partir do store do Home Manager.
    xdg.configFile."albert/config".text = ''
      [General]
      frontend=widgetsboxmodel-ng
      showTray=false
      telemetry=false

      [applications]
      enabled=true
      global_handler_enabled=true

      [chromium]
      enabled=true
      fuzzy=false
      global_handler_enabled=false
      trigger=bm

      [debug]
      enabled=false

      [path]
      enabled=false

      [system]
      command_lock=loginctl lock-session
      command_logout=bash -c 'if [[ "$XDG_SESSION_DESKTOP" == KDE ]] || [[ "$DESKTOP_SESSION" == plasmawayland* ]] || [[ "$DESKTOP_SESSION" == plasma* ]]; then qdbus org.kde.ksmserver /KSMServer logout 0 3 3 2>/dev/null || loginctl terminate-session "$XDG_SESSION_ID"; else loginctl terminate-session "$XDG_SESSION_ID" 2>/dev/null || true; fi'
      command_poweroff=systemctl poweroff -i
      command_reboot=systemctl reboot -i
      enabled=true
      logout_enabled=true
      title_logout=Quit All Applications
      title_poweroff=Shutdown
      trigger=sys

      [widgetsboxmodel-ng]
      alwaysOnTop=true
      clearOnHide=true
      debug=false
      displayScrollbar=false
      followCursor=true
      hideOnFocusLoss=true
      historySearch=true
      itemCount=10
      quitOnClose=false
      showCentered=true
    '';

    # Serviço systemd user para iniciar o Albert na sessão gráfica.
    systemd.user.services.albert = {
      Unit = {
        Description = "Albert Launcher";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.albert}/bin/albert";
        Nice = 10;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        Restart = "always";
        RestartSec = "0s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
