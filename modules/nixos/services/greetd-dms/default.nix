# =============================================================================
# NixOS: greetd + tuigreet (Wayland-friendly login manager)
#
# O que é:
# - Habilita greetd e configura sessão Wayland funcional com tuigreet.
#
# Por quê:
# - Substitui SDDM/GDM por um login manager leve e Wayland-friendly.
# - tuigreet é o greeter padrão, estável e bem integrado com greetd.
# - Corrige problema de login loop causado por sessão logind inválida.
#
# Como usar:
# - No host (ex.: hosts/inspiron/default.nix):
#     rag.services.greetdDms.enable = true;
#
# Por que funciona:
# - A sessão deve ter class=user e type=wayland para que logind crie
#   uma sessão válida com seat0 anexado.
# - Sem isso, UWSM herda uma sessão "manager" sem seat e Hyprland falha.
# - O PAM é configurado com os parâmetros corretos para pam_systemd.so.
#
# Notas:
# - O rice DMS (DankMaterialShell) é carregado pelo usuário via Home Manager.
# - O usuário "greeter" é criado automaticamente pelo módulo greetd do NixOS.
# - UWSM é usado para iniciar Hyprland quando programs.hyprland.withUWSM = true.
# =============================================================================
{ config, lib, pkgs, ... }:

let
  cfg = config.rag.services.greetdDms;
  greeterUser = cfg.user;

  # Hyprland launcher (binário start-hyprland).
  # Usamos o path do pacote configurado pelo NixOS quando disponível.
  hyprlandPkg = config.programs.hyprland.package or pkgs.hyprland;

  # PAM modules (paths absolutos para evitar PAM_MODULE_UNKNOWN em NixOS).
  pam = pkgs.pam;
  pam_unix = "${pam}/lib/security/pam_unix.so";
  pam_env = "${pam}/lib/security/pam_env.so";
  pam_keyinit = "${pam}/lib/security/pam_keyinit.so";
  pam_limits = "${pam}/lib/security/pam_limits.so";
  pam_permit = "${pam}/lib/security/pam_permit.so";
  pam_systemd = "${pkgs.systemd}/lib/security/pam_systemd.so";
  pam_gnome_keyring = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";

  # Comando tuigreet com configuração otimizada para sessões Wayland
  tuigreetCmd = lib.concatStringsSep " " [
    "${pkgs.tuigreet}/bin/tuigreet"
    "--time"
    "--remember"
    "--remember-user-session"
    "--asterisks"
    "--cmd ${lib.escapeShellArg cfg.command}"
  ];
in
{
  options.rag.services.greetdDms = {
    enable = lib.mkEnableOption "greetd com tuigreet (gerenciador de login Wayland-friendly)";

    user = lib.mkOption {
      type = lib.types.str;
      default = "greeter";
      description = ''
        Usuário que executa o processo greeter do greetd.
        Por padrão usa "greeter", o usuário de sistema criado automaticamente
        pelo módulo services.greetd do NixOS. Altere apenas se souber o que está fazendo.
      '';
    };

    command = lib.mkOption {
      type = lib.types.str;
      default = "uwsm start hyprland-uwsm.desktop";
      description = ''
        Comando da sessão lançado após o login.
        Padrão: inicia Hyprland via UWSM usando o Desktop Entry gerado pelo Hyprland.

        Nota: para passar argumentos ao compositor via `uwsm start`, use `--`.

        Alternativa (fallback quando o Desktop Entry falhar):
        - "uwsm start -e -D Hyprland -- ${hyprlandPkg}/bin/start-hyprland --no-nixgl"

        Use "Hyprland" apenas se withUWSM = false.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # ==========================================================================
    # Configuração do greetd
    # ==========================================================================
    services.greetd = {
      enable = true;
      settings = {
        terminal = {
          vt = 1;
        };
        default_session = {
          user = greeterUser;
          command = tuigreetCmd;
        };
      };
    };

    # ==========================================================================
    # PAM para greetd: Sessão Wayland com seat
    #
    # CRÍTICO: Configura pam_systemd.so com class=user type=wayland para que
    # logind crie uma sessão válida com:
    # - Class: user (não "manager")
    # - Type: wayland
    # - Seat: seat0
    #
    # Isso é necessário porque as opções estruturadas do NixOS (startSession = true)
    # não permitem especificar esses parâmetros. Sem eles, a sessão não funciona
    # com UWSM e Hyprland.
    #
    # Referência: docs/GREETD_FINAL_SOLUTION.md
    # ==========================================================================
    security.pam.services.greetd = {
      allowNullPassword = lib.mkForce false;
      unixAuth = true;
      text = lib.mkForce ''
        # PAM para greetd - Sessão Wayland funcional
        # NÃO MODIFICAR sem entender docs/GREETD_FINAL_SOLUTION.md

        # Autenticação
        auth     required ${pam_unix} nullok try_first_pass
        auth     optional ${pam_gnome_keyring}

        # Verificação de conta
        account  required ${pam_unix}

        # Senha (para troca de senha)
        password required ${pam_unix} nullok yescrypt
        password optional ${pam_gnome_keyring} use_authtok

        # Sessão - ORDEM IMPORTA
        session  required ${pam_unix}
        session  required ${pam_env} conffile=/etc/pam/environment readenv=0
        session  optional ${pam_keyinit} force revoke
        session  required ${pam_limits}

        # CRÍTICO: class=user type=wayland para sessão Wayland válida
        # - class=user: logind cria sessão com seat (não "manager")
        # - type=wayland: define XDG_SESSION_TYPE=wayland e aloca VT
        session  required ${pam_systemd} class=user type=wayland

        # Gnome Keyring (desbloqueio automático)
        session  optional ${pam_gnome_keyring} auto_start

        # Fallback para módulos opcionais
        session  optional ${pam_permit}
      '';
    };

    # ==========================================================================
    # Pacotes necessários
    # ==========================================================================
    environment.systemPackages = with pkgs; [
      tuigreet
      # greetd já é instalado pelo módulo services.greetd
    ];

    # ==========================================================================
    # Garantir que logind não mata processos do usuário no logout
    # Isso é importante para sessões Wayland que podem ter processos em background
    # ==========================================================================
    services.logind.settings.Login.KillUserProcesses = lib.mkDefault false;
  };
}
