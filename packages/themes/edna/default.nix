# packages/themes/edna/default.nix
#
# Derivação para o ecossistema do tema Edna (Light e Dark) + script executável edna-switcher.
# Contém:
#   - edna-assets: Plasma Look & Feel, Color Schemes, Kvantum, GTK, Konsole, Aurorae e Wallpapers.
#   - edna-switcher: Script executável em Bash para alternância entre temas Light e Dark.

{
  lib,
  stdenvNoCC,
  writeShellScriptBin,
  fetchFromGitHub ? null,
  kdePackages ? null,
  glib ? null,
}:
let
  # Script de transição dia/noite (edna-switcher)
  edna-switcher = writeShellScriptBin "edna-switcher" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Limpeza de temas legados/manuais para evitar conflitos com Nix Store
    # Apaga apenas se for um diretório real (mutável) e não um symlink.
    for dir in "$HOME/.local/share/plasma/look-and-feel/com.github.PaulXFCE.Edna" \
               "$HOME/.local/share/plasma/look-and-feel/com.github.PaulXFCE.Edna-Light" \
               "$HOME/.local/share/aurorae/themes/Edna" \
               "$HOME/.local/share/aurorae/themes/Edna-Light"; do
      if [ -d "$dir" ] && [ ! -L "$dir" ]; then
        echo "[edna-switcher] Aviso: Removendo tema legado local (mutável) para evitar conflito com NixStore: $dir"
        rm -rf "$dir"
      fi
    done

    MODE="''${1:-auto}"

    if [ "$MODE" = "auto" ]; then
      HOUR=$(date +%H)
      if [ "$HOUR" -ge 7 ] && [ "$HOUR" -lt 19 ]; then
        MODE="light"
      else
        MODE="dark"
      fi
    fi

    echo "[edna-switcher] Aplicando variante do tema Edna: $MODE"

    if [ "$MODE" = "light" ]; then
      COLOR_SCHEME="Edna-Light"
      LOOK_AND_FEEL="com.github.PaulXFCE.Edna-Light"
      KVANTUM_THEME="Edna-Light"
      GTK_THEME="Edna-Light"
      GTK_COLOR_SCHEME="prefer-light"
      KONSOLE_SCHEME="Edna-Light"
      AURORAE_THEME="__aurorae__svg_Edna-Light"
      WALLPAPER_NAME="Edna-Day"
    else
      COLOR_SCHEME="Edna"
      LOOK_AND_FEEL="com.github.PaulXFCE.Edna"
      KVANTUM_THEME="Edna"
      GTK_THEME="Edna"
      GTK_COLOR_SCHEME="prefer-dark"
      KONSOLE_SCHEME="Edna"
      AURORAE_THEME="__aurorae__svg_Edna"
      WALLPAPER_NAME="Edna-Night"
    fi

    # 1. Esquema de Cores do Plasma / KDE
    if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
      plasma-apply-colorscheme "$COLOR_SCHEME" || true
    fi

    # 2. Look and Feel (Tema Global do Plasma)
    if command -v lookandfeeltool >/dev/null 2>&1; then
      lookandfeeltool -a "$LOOK_AND_FEEL" || true
    fi

    # 3. Tema Kvantum (Qt)
    if command -v kvantummanager >/dev/null 2>&1; then
      kvantummanager --set "$KVANTUM_THEME" || true
    fi
    KV_CONFIG="$HOME/.config/Kvantum/kvantum.kvconfig"
    mkdir -p "$(dirname "$KV_CONFIG")"
    if command -v kwriteconfig6 >/dev/null 2>&1; then
      kwriteconfig6 --file "$KV_CONFIG" --group General --key theme "$KVANTUM_THEME" || true
    fi

    # 4. Tema GTK & Esquema de Cores GNOME/GTK4
    if command -v gsettings >/dev/null 2>&1; then
      gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" || true
      gsettings set org.gnome.desktop.interface color-scheme "$GTK_COLOR_SCHEME" || true
    fi

    # 5. Perfil do Konsole
    if command -v kwriteconfig6 >/dev/null 2>&1; then
      kwriteconfig6 --file "$HOME/.config/konsolerc" --group "Desktop Entry" --key DefaultProfile "$KONSOLE_SCHEME.profile" || true
    fi

    # 6. Decoração de Janela Aurorae (KWin)
    if command -v kwriteconfig6 >/dev/null 2>&1; then
      kwriteconfig6 --file "$HOME/.config/kwinrc" --group "org.kde.kwin.decoration" --key theme "$AURORAE_THEME" || true
      if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.KWin /KWin reconfigure || true
      elif command -v qdbus >/dev/null 2>&1; then
        qdbus org.kde.KWin /KWin reconfigure || true
      fi
    fi

    # 7. Wallpaper do Plasma Desktop
    WALLPAPER_PATH="$HOME/.local/share/wallpapers/Edna/$WALLPAPER_NAME.png"
    if [ ! -f "$WALLPAPER_PATH" ]; then
      WALLPAPER_PATH="$HOME/.local/share/wallpapers/Edna/$WALLPAPER_NAME.jpg"
    fi
    if [ ! -f "$WALLPAPER_PATH" ]; then
      if [ "$MODE" = "light" ]; then
        WALLPAPER_PATH="$HOME/.local/share/wallpapers/Edna/Cartoon-Floating-Islands.png"
      else
        WALLPAPER_PATH="$HOME/.local/share/wallpapers/Edna/Cartoon-Lofi-Night.png"
      fi
    fi
    if [ ! -f "$WALLPAPER_PATH" ]; then
      WALLPAPER_PATH=$(find "$HOME/.local/share/wallpapers/Edna" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.svg" \) 2>/dev/null | head -n 1 || true)
    fi

    if [ -n "$WALLPAPER_PATH" ] && [ -f "$WALLPAPER_PATH" ] && command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
      echo "[edna-switcher] Aplicando wallpaper: $WALLPAPER_PATH"
      plasma-apply-wallpaperimage "$WALLPAPER_PATH" || true
    fi

    echo "[edna-switcher] Variante $MODE aplicada com sucesso."
  '';

  # Derivação de Assets do Tema Edna
  edna-assets = stdenvNoCC.mkDerivation {
    pname = "edna-assets";
    version = "1.0.0";

    src = ./.;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
            runHook preInstall

            # Diretores de saída do pacote
            mkdir -p "$out/share/color-schemes"
            mkdir -p "$out/share/plasma/look-and-feel/com.github.PaulXFCE.Edna/contents"
            mkdir -p "$out/share/plasma/look-and-feel/com.github.PaulXFCE.Edna-Light/contents"
            mkdir -p "$out/share/plasma/desktoptheme/Edna"
            mkdir -p "$out/share/plasma/desktoptheme/Edna-Light"
            mkdir -p "$out/share/Kvantum/Edna"
            mkdir -p "$out/share/Kvantum/Edna-Light"
            mkdir -p "$out/share/themes/Edna/gtk-3.0"
            mkdir -p "$out/share/themes/Edna-Light/gtk-3.0"
            mkdir -p "$out/share/konsole"
            mkdir -p "$out/share/aurorae/themes/Edna"
            mkdir -p "$out/share/aurorae/themes/Edna-Light"
            mkdir -p "$out/share/wallpapers/Edna"

            # 1. Color Schemes
            cat << 'EOF' > "$out/share/color-schemes/Edna.colors"
      [General]
      Name=Edna
      ColorScheme=Edna
      [Colors:Window]
      BackgroundNormal=30,32,44
      ForegroundNormal=225,227,235
      [Colors:Button]
      BackgroundNormal=40,43,58
      ForegroundNormal=225,227,235
      [Colors:Selection]
      BackgroundNormal=92,107,192
      ForegroundNormal=255,255,255
      EOF

            cat << 'EOF' > "$out/share/color-schemes/Edna-Light.colors"
      [General]
      Name=Edna-Light
      ColorScheme=Edna-Light
      [Colors:Window]
      BackgroundNormal=245,247,250
      ForegroundNormal=40,42,54
      [Colors:Button]
      BackgroundNormal=230,233,240
      ForegroundNormal=40,42,54
      [Colors:Selection]
      BackgroundNormal=92,107,192
      ForegroundNormal=255,255,255
      EOF

            # 2. Look and Feel
            cat << 'EOF' > "$out/share/plasma/look-and-feel/com.github.PaulXFCE.Edna/metadata.json"
      {
          "KPlugin": {
              "Name": "Edna",
              "Description": "Edna Dark Theme Look and Feel",
              "Id": "com.github.PaulXFCE.Edna",
              "ServiceTypes": ["Plasma/LookAndFeel"]
          }
      }
      EOF
            cat << 'EOF' > "$out/share/plasma/look-and-feel/com.github.PaulXFCE.Edna/contents/defaults"
      [kdeglobals][General]
      ColorScheme=Edna
      EOF

            cat << 'EOF' > "$out/share/plasma/look-and-feel/com.github.PaulXFCE.Edna-Light/metadata.json"
      {
          "KPlugin": {
              "Name": "Edna Light",
              "Description": "Edna Light Theme Look and Feel",
              "Id": "com.github.PaulXFCE.Edna-Light",
              "ServiceTypes": ["Plasma/LookAndFeel"]
          }
      }
      EOF
            cat << 'EOF' > "$out/share/plasma/look-and-feel/com.github.PaulXFCE.Edna-Light/contents/defaults"
      [kdeglobals][General]
      ColorScheme=Edna-Light
      EOF

            # 3. Kvantum Themes
            cat << 'EOF' > "$out/share/Kvantum/Edna/Edna.kvconfig"
      [General]
      theme=Edna
      EOF
            cat << 'EOF' > "$out/share/Kvantum/Edna-Light/Edna-Light.kvconfig"
      [General]
      theme=Edna-Light
      EOF

            # 4. GTK Themes
            cat << 'EOF' > "$out/share/themes/Edna/index.theme"
      [Desktop Entry]
      Type=X-GNOME-Metatheme
      Name=Edna
      Comment=Edna GTK Dark Theme
      Encoding=UTF-8

      [X-GNOME-Metatheme]
      GtkTheme=Edna
      MetacityTheme=Edna
      IconTheme=Papirus-Dark
      EOF

            cat << 'EOF' > "$out/share/themes/Edna/gtk-3.0/gtk.css"
      @import url("resource:///org/gnome/adwaita/gtk-dark.css");
      EOF

            cat << 'EOF' > "$out/share/themes/Edna-Light/index.theme"
      [Desktop Entry]
      Type=X-GNOME-Metatheme
      Name=Edna-Light
      Comment=Edna GTK Light Theme
      Encoding=UTF-8

      [X-GNOME-Metatheme]
      GtkTheme=Edna-Light
      MetacityTheme=Edna-Light
      IconTheme=Papirus
      EOF

            cat << 'EOF' > "$out/share/themes/Edna-Light/gtk-3.0/gtk.css"
      @import url("resource:///org/gnome/adwaita/gtk.css");
      EOF

            # 5. Konsole Profiles
            cat << 'EOF' > "$out/share/konsole/Edna.colorscheme"
      [General]
      Description=Edna Dark
      Opacity=0.95
      [Background]
      Color=30,32,44
      [Foreground]
      Color=225,227,235
      EOF

            cat << 'EOF' > "$out/share/konsole/Edna-Light.colorscheme"
      [General]
      Description=Edna Light
      Opacity=1.0
      [Background]
      Color=245,247,250
      [Foreground]
      Color=40,42,54
      EOF

            cat << 'EOF' > "$out/share/konsole/Edna.profile"
      [General]
      Name=Edna
      Parent=FALLBACK/
      ColorScheme=Edna
      EOF

            cat << 'EOF' > "$out/share/konsole/Edna-Light.profile"
      [General]
      Name=Edna-Light
      Parent=FALLBACK/
      ColorScheme=Edna-Light
      EOF

            # 6. Aurorae Window Decoration
            cat << 'EOF' > "$out/share/aurorae/themes/Edna/auroraerc"
      [General]
      TitleAlignment=Center
      ButtonSize=Normal
      EOF

            cat << 'EOF' > "$out/share/aurorae/themes/Edna-Light/auroraerc"
      [General]
      TitleAlignment=Center
      ButtonSize=Normal
      EOF

            # 7. Wallpapers (Wallpapers diurno e noturno em 8K Glassmorphism)
            cat << 'EOF' > "$out/share/wallpapers/Edna/metadata.json"
      {
          "KPlugin": {
              "Name": "Edna Wallpapers",
              "Id": "Edna"
          }
      }
      EOF
      if [ -d "$src/wallpapers" ]; then
        cp -r "$src/wallpapers/"*.png "$out/share/wallpapers/Edna/" 2>/dev/null || true
      fi

            runHook postInstall
    '';

    meta = {
      description = "Assets declarativos do tema Edna (Light e Dark) para KDE Plasma, Kvantum, GTK, Konsole e Aurorae";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
    };
  };
in
{
  inherit edna-assets edna-switcher;
}
