{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kryonix.features.caelestiaTheme;
  caelestiaPkg = pkgs.callPackage ../../../packages/themes/caelestia { };
in
{
  options.kryonix.features.caelestiaTheme = {
    enable = lib.mkEnableOption "Tema Caelestia KDE com QML shell e KWin Blur (System-Level)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      caelestiaPkg
      pkgs.quickshell
    ];

    environment.sessionVariables = {
      QML2_IMPORT_PATH = lib.mkForce "${caelestiaPkg}/lib/qt6/qml:\${QML2_IMPORT_PATH:-}";
      CAELESTIA_LIB_DIR = "${caelestiaPkg}/lib/caelestia";
      CAELESTIA_BIN_DIR = "${caelestiaPkg}/bin";
    };

    systemd.user.services.caelestia-shell = {
      description = "Caelestia Shell";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      before = [ "xdg-desktop-autostart.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkgs.quickshell}/bin/quickshell -n -p ${caelestiaPkg}/share/quickshell/caelestia/shell.qml";
        Environment = [
          "PATH=${caelestiaPkg}/bin:${pkgs.quickshell}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
          "QML2_IMPORT_PATH=${caelestiaPkg}/lib/qt6/qml"
          "CAELESTIA_LIB_DIR=${caelestiaPkg}/lib/caelestia"
          "CAELESTIA_BIN_DIR=${caelestiaPkg}/bin"
          "CAELESTIA_SHELL_CONFIG=${caelestiaPkg}/share/quickshell/caelestia/shell.qml"
          "QS_NO_RELOAD_POPUP=1"
          "QS_DROP_EXPENSIVE_FONTS=1"
          "QS_DISABLE_CRASH_HANDLER=1"
          "QSG_RENDER_LOOP=threaded"
          "QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000"
        ];
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStopSec = "5s";
        Slice = "session.slice";
      };
    };

    environment.etc = {
      "xdg/kwinrc".text = ''
        [Plugins]
        blurEnabled=true
        translucencyEnabled=true
        kwin_workspace_trackerEnabled=true

        [Effect-blur]
        BlurStrength=15
        NoiseStrength=0
      '';
      "xdg/plasmashellrc".text = ''
        [Shell]
        ShellPackage=caelestia.desktop
      '';
      "xdg/kscreenlockerrc".text = ''
        [Greeter]
        WallpaperPlugin=org.kde.image
      '';
      "xdg/kdeglobals".text = ''
        [Icons]
        Theme=yet-another-monochrome-icon-set
      '';
    };

    environment.extraSetup = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/quickshell.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=Quickshell
      NoDisplay=true
      Exec=${pkgs.quickshell}/bin/quickshell
      X-KDE-Wayland-Interfaces=zkde_screencast_unstable_v1,org_kde_plasma_window_management
      EOF
    '';
  };
}
