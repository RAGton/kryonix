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

    home.file.".local/share/warp-terminal/themes/caelestia.yaml".text = ''
      accent: '#89b4fa'
      background: '#11111B99'
      details: darker
      foreground: '#cdd6f4'
      terminal_colors:
        normal:
          black: '#45475a'
          red: '#f38ba8'
          green: '#a6e3a1'
          yellow: '#f9e2af'
          blue: '#89b4fa'
          magenta: '#f5c2e7'
          cyan: '#94e2d5'
          white: '#bac2de'
        bright:
          black: '#585b70'
          red: '#f38ba8'
          green: '#a6e3a1'
          yellow: '#f9e2af'
          blue: '#89b4fa'
          magenta: '#f5c2e7'
          cyan: '#94e2d5'
          white: '#a6adc8'
    '';
  };
}
