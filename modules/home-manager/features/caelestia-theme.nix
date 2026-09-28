{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kryonix.home.features.caelestiaTheme;
  caelestiaPkg = pkgs.callPackage ../../../packages/themes/caelestia { };
in
{
  options.kryonix.home.features.caelestiaTheme = {
    enable = lib.mkEnableOption "Tema Caelestia KDE com QML shell e KWin Blur";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      caelestiaPkg
    ];

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    home.sessionVariables = {
      QML2_IMPORT_PATH = "${caelestiaPkg}/lib/qt6/qml:\${QML2_IMPORT_PATH:-}";
      CAELESTIA_LIB_DIR = "${caelestiaPkg}/lib/caelestia";
      CAELESTIA_BIN_DIR = "${caelestiaPkg}/bin";
    };

    systemd.user.sessionVariables = {
      QML2_IMPORT_PATH = "${caelestiaPkg}/lib/qt6/qml";
      CAELESTIA_LIB_DIR = "${caelestiaPkg}/lib/caelestia";
      CAELESTIA_BIN_DIR = "${caelestiaPkg}/bin";
    };

    programs.plasma.configFile = {
      kwinrc = {
        Plugins = {
          blurEnabled = true;
          translucencyEnabled = true;
          kwin_workspace_trackerEnabled = true;
        };
        "Effect-blur" = {
          BlurStrength = 15;
          NoiseStrength = 0;
        };
      };
      plasmashellrc = {
        Shell = {
          ShellPackage = "caelestia.desktop";
        };
      };
      kscreenlockerrc = {
        Greeter = {
          WallpaperPlugin = "org.kde.image";
        };
      };
    };

    programs.plasma.workspace = {
      iconTheme = lib.mkForce "yet-another-monochrome-icon-set";
    };
  };
}
