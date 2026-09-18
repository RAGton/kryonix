{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kryonix.shell.caelestia;
  # Paleta Caelestia alinhada com desktop/branding/kryonix/palette.nix (dark).
  # Antes usava tons Tailwind blue (#76aef5, #101726, ...) desconectados da
  # identidade Kryonix. Agora deriva do accent oficial (#38bdf8 / #00d4ff) e
  # dos backgrounds oficiais (#0b0f14, #0f1419, #14191e).
  brand = import ../branding/kryonix/palette.nix;
  p = brand.dark;
  blueScheme = {
    name = "rag-blue";
    flavour = "blue";
    mode = "dark";
    colours = {
      # Mantidos os campos do Material 3 (Caelestia espera este formato).
      # Cores principais derivadas da paleta Kryonix (accentBlue #38bdf8).
      primary_paletteKeyColor = "38bdf8";
      secondary_paletteKeyColor = "8fb2dd";
      tertiary_paletteKeyColor = "00d4ff";
      neutral_paletteKeyColor = p.backgroundDeep.hex;       # 0b0f14
      neutral_variant_paletteKeyColor = p.borderSubtle.hex;  # 1e2d3d
      background = p.backgroundDeep.hex;                     # 0b0f14
      onBackground = p.textPrimary.hex;                      # e8f4f8
      surface = p.backgroundDeep.hex;
      surfaceDim = p.backgroundDeep.hex;
      surfaceBright = p.borderSubtle.hex;
      surfaceContainerLowest = p.backgroundDeep.hex;
      surfaceContainerLow = p.backgroundSoft.hex;            # 0f1419
      surfaceContainer = p.surface.hex;                      # 14191e
      surfaceContainerHigh = "1c232d";
      surfaceContainerHighest = "232b37";
      onSurface = p.textPrimary.hex;
      surfaceVariant = p.borderSubtle.hex;
      onSurfaceVariant = p.textMuted.hex;                    # 8badbf
      inverseSurface = p.textPrimary.hex;
      inverseOnSurface = p.backgroundDeep.hex;
      outline = p.textMuted.hex;
      outlineVariant = p.borderSubtle.hex;
      shadow = "000000";
      scrim = "000000";
      surfaceTint = p.accentBlue.hex;                        # 38bdf8
      primary = p.accentBlue.hex;
      onPrimary = p.backgroundDeep.hex;
      primaryContainer = "0c4a6e";
      onPrimaryContainer = "e0f2fe";
      inversePrimary = "7dd3fc";
      secondary = "8fb2dd";
      onSecondary = "0e1b2b";
      secondaryContainer = "20344d";
      onSecondaryContainer = "d4e3fa";
      tertiary = p.accentCyan.hex;                            # 00d4ff
      onTertiary = p.backgroundDeep.hex;
      tertiaryContainer = "003a4d";
      onTertiaryContainer = "cffafe";
      error = p.danger.hex;                                  # ff4455
      onError = p.backgroundDeep.hex;
      errorContainer = "7f1d1d";
      onErrorContainer = "fecaca";
      success = p.success.hex;                               # 39ff14
      onSuccess = p.backgroundDeep.hex;
      successContainer = "14532d";
      onSuccessContainer = "bbf7d0";
      primaryFixed = "bae6fd";
      primaryFixedDim = "7dd3fc";
      onPrimaryFixed = p.backgroundDeep.hex;
      onPrimaryFixedVariant = "0c4a6e";
      secondaryFixed = "d4e3fa";
      secondaryFixedDim = "8fb2dd";
      onSecondaryFixed = "0e1b2b";
      onSecondaryFixedVariant = "20344d";
      tertiaryFixed = "cffafe";
      tertiaryFixedDim = "67e8f9";
      onTertiaryFixed = p.backgroundDeep.hex;
      onTertiaryFixedVariant = "003a4d";
      # Terminal palette — preserva a estética Caelestia, mas com accent Kryonix.
      term0 = p.backgroundDeep.hex;
      term1 = p.accentBlue.hex;
      term2 = p.accentCyan.hex;
      term3 = "67e8f9";
      term4 = "a5f3fc";
      term5 = "7dd3fc";
      term6 = "bae6fd";
      term7 = p.textPrimary.hex;
      term8 = p.textMuted.hex;
      term9 = p.accentBlue.hex;
      term10 = p.accentCyan.hex;
      term11 = "ffffff";
      term12 = p.accentBlue.hex;
      term13 = "8fb2dd";
      term14 = "7dd3fc";
      term15 = "ffffff";
    };
  };
  shellSettingsFile =
    if cfg.settings != { } then
      pkgs.writeText "caelestia-shell.json" (builtins.toJSON cfg.settings)
    else
      null;
  shellTokensFile =
    if cfg.tokens != { } then
      pkgs.writeText "caelestia-shell-tokens.json" (builtins.toJSON cfg.tokens)
    else
      null;
  shellSchemeFile = pkgs.writeText "caelestia-scheme.json" (builtins.toJSON cfg.scheme);
  shellWallpaperPathFile = pkgs.writeText "caelestia-wallpaper-path.txt" "${builtins.toString config.wallpaper}\n";

  writeMutableFile = target: sourcePath: ''
    target_dir="$(${pkgs.coreutils}/bin/dirname "${target}")"

    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$target_dir"

    if [ -L "${target}" ] || [ ! -e "${target}" ] || ! ${pkgs.diffutils}/bin/cmp -s ${sourcePath} "${target}"; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "${target}"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm644 ${sourcePath} "${target}"
    fi
  '';
in
{
  options.kryonix.shell.caelestia = {
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

    scheme = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = blueScheme;
      description = "Estado inicial de `~/.local/state/caelestia/scheme.json`.";
    };
  };

  config = lib.mkIf ((config.kryonix.shell.backend or null) == "caelestia") {
    kryonix.shell.caelestia.settings.launcher.useFuzzy.apps = lib.mkDefault false;

    # Caelestia Hybrid Mode: Symlinks point to the live repository
    # This allows the UI to modify files and the watcher to commit them.
    xdg.configFile."caelestia/shell.json".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/kryonixos/user/caelestia/shell.json";

    xdg.configFile."caelestia/shell-tokens.json".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/kryonixos/user/caelestia/shell-tokens.json";

    home.file.".local/state/caelestia/scheme.json".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/kryonixos/user/caelestia/scheme.json";

    # Compatibility symlink for QuickShell if needed
    home.file.".config/quickshell/shell.json".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/kryonixos/user/caelestia/shell.json";

    home.activation.caelestiaHybridInit = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      caelestia_repo_dir="/etc/kryonixos/user/caelestia"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$caelestia_repo_dir"

      # Initialize files if they don't exist in the repo
      if [ ! -e "$caelestia_repo_dir/shell.json" ] && [ "${
        if shellSettingsFile != null then "true" else "false"
      }" = "true" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp ${
          if shellSettingsFile != null then shellSettingsFile else "/dev/null"
        } "$caelestia_repo_dir/shell.json"
      fi
      if [ ! -e "$caelestia_repo_dir/shell-tokens.json" ] && [ "${
        if shellTokensFile != null then "true" else "false"
      }" = "true" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp ${
          if shellTokensFile != null then shellTokensFile else "/dev/null"
        } "$caelestia_repo_dir/shell-tokens.json"
      fi
      if [ ! -e "$caelestia_repo_dir/scheme.json" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp ${shellSchemeFile} "$caelestia_repo_dir/scheme.json"
      fi
    '';

    home.activation.caelestiaMutableState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      applications_dir="${config.xdg.dataHome}/applications"
      if [ -d "$applications_dir" ]; then
        $DRY_RUN_CMD ${pkgs.desktop-file-utils}/bin/update-desktop-database "$applications_dir"
      fi

      caelestia_state_dir="${config.xdg.stateHome}/caelestia"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "$caelestia_state_dir"/apps.sqlite*

      ${writeMutableFile "${config.home.homeDirectory}/.local/state/caelestia/wallpaper/path.txt" shellWallpaperPathFile}
    '';
  };
}
