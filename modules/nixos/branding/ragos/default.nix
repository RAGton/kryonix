# =============================================================================
# Módulo NixOS: Branding do sistema (RagOS)
# Autor: rag
#
# O que é
# - Um módulo *reutilizável* para “caracterizar” o NixOS como RagOS.
# - Ajusta identidade do sistema em lugares padrão do Linux desktop:
#   - /etc/os-release (PRETTY_NAME, NAME, ID, VERSION_ID)
#   - /etc/issue (texto do console/login)
#
# Por quê
# - Mantém o rebranding *declarativo* e centralizado, sem “gambiarras” por host.
# - Evita espalhar strings (nome/versão) em vários arquivos.
#
# Como usar
# - Importe este módulo em um host (ex.: `hosts/inspiron/default.nix`) ou em um módulo comum.
# - Depois habilite:
#     ragos.enable = true;
#     ragos.versionId = "25.11"; # (se quiser espelhar o stateVersion)
#
# Nota importante sobre versões
# - `system.stateVersion` NÃO deve ser mudado só por branding.
# - `ragos.versionId` é apenas o que aparece em /etc/os-release.
# =============================================================================
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.ragos;
  displayName = lib.concatStringsSep " " (
    lib.filter (part: part != "") [
      cfg.prettyName
      cfg.edition
    ]
  );
  ragosWallpaper = ../../../../files/wallpaper/ragos-system-4k.png;
  ragosGdmWallpaper = ../../../../files/wallpaper/ragos-gdm-4k.png;
  ragosAvatar = ../../../../files/wallpaper/ragos-ava.png;
  grubSplash =
    pkgs.runCommand "ragos-grub-splash.png"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        magick "${ragosWallpaper}" \
          -resize 1920x1080^ \
          -gravity center \
          -extent 1920x1080 \
          -strip PNG32:"$out"
      '';
  plymouthTheme =
    pkgs.runCommand "ragos-plymouth-theme"
      {
        nativeBuildInputs = [
          pkgs.imagemagick
          pkgs.coreutils
        ];
      }
      ''
              themeDir="$out/share/plymouth/themes/ragos"
              imageDir="$themeDir/images"
              mkdir -p "$imageDir"

              cp ${ragosWallpaper} "$imageDir/background.png"
              cp ${ragosAvatar} "$imageDir/logo.png"

              for i in $(seq 1 30); do
                frame="$(printf '%04d' "$i")"
                magick "$imageDir/logo.png" \
                  -background none \
                  -gravity center \
                  -resize 96x96 \
                  -extent 96x96 \
                  "$imageDir/throbber-$frame.png"
              done

              cat > "$themeDir/ragos.plymouth" <<EOF
        [Plymouth Theme]
        Name=RagOS
        Description=Tema de boot do RagOS
        ModuleName=two-step

        [two-step]
        Font=Cantarell 20
        ImageDir=$imageDir
        BackgroundStartColor=0x05070c
        BackgroundEndColor=0x05070c
        ProgressBarBackgroundColor=0x1b2433
        ProgressBarForegroundColor=0xe9eef9
        DialogHorizontalAlignment=.5
        DialogVerticalAlignment=.82
        HorizontalAlignment=.5
        VerticalAlignment=.74
        Transition=fade-in
        TransitionDuration=0.35
        MessageBelowAnimation=true
        UseEndAnimation=false

        [boot-up]
        UseEndAnimation=false
        UseFirmwareBackground=false

        [shutdown]
        UseEndAnimation=false
        UseFirmwareBackground=false

        [reboot]
        UseEndAnimation=false
        UseFirmwareBackground=false
        EOF
      '';
  # Conteúdo do /etc/os-release.
  # Usamos um conjunto pequeno e compatível (muitas ferramentas só precisam disso).
  osReleaseText = ''
    NAME="NixOS (RagOS)"
    PRETTY_NAME=${lib.escapeShellArg displayName}
    ID=nixos
    ID_LIKE=nixos
    VERSION_ID=${lib.escapeShellArg cfg.versionId}
    LOGO=nix-snowflake
    HOME_URL="https://nixos.org/"
  '';
in
{
  options.ragos = {
    enable = lib.mkEnableOption "Ativa branding do sistema como RagOS";

    prettyName = lib.mkOption {
      type = lib.types.str;
      default = "RagOS";
      description = "Nome amigável (PRETTY_NAME) exibido por ferramentas/GUI.";
    };

    edition = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Sufixo opcional da edição do sistema.
        Exemplo: `VE` para exibir `RagOS VE`.
      '';
    };

    versionId = lib.mkOption {
      type = lib.types.str;
      default = "25.11";
      description = "Versão exibida (VERSION_ID) em /etc/os-release.";
    };

    issueText = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = ''
        Texto para /etc/issue (login/TTY).

        Dica: suporta escapes do getty, como:
        - \r: release do kernel
        - \m: arquitetura
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Substitui o /etc/os-release padrão do NixOS.
    # Se não for mkForce, pode acontecer de ficar duplicado/mesclado.
    environment.etc."os-release".text = lib.mkForce osReleaseText;

    # Texto exibido em TTY/getty.
    environment.etc."issue".text =
      if cfg.issueText != null then
        cfg.issueText
      else
        ''
          ${displayName}
          Kernel: \r \m
          Host: \n
        '';

    programs.dconf.profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/desktop/background" = {
            picture-uri = "file://${ragosGdmWallpaper}";
            picture-uri-dark = "file://${ragosGdmWallpaper}";
            picture-options = "zoom";
            primary-color = "#05070c";
            secondary-color = "#05070c";
            color-shading-type = "solid";
          };
          "org/gnome/desktop/screensaver" = {
            picture-uri = "file://${ragosGdmWallpaper}";
            picture-uri-dark = "file://${ragosGdmWallpaper}";
            picture-options = "zoom";
            primary-color = "#05070c";
            secondary-color = "#05070c";
            color-shading-type = "solid";
          };
        };
      }
    ];

    boot = {
      plymouth = {
        enable = lib.mkDefault true;
        theme = lib.mkForce "ragos";
        themePackages = lib.mkForce [ plymouthTheme ];
      };

      loader.grub = {
        splashImage = lib.mkForce grubSplash;
        gfxmodeEfi = lib.mkDefault "1920x1080";
        gfxmodeBios = lib.mkDefault "1920x1080";
        extraConfig = lib.mkAfter ''
          set menu_color_normal=light-gray/black
          set menu_color_highlight=white/dark-gray
          set color_normal=light-gray/black
          set color_highlight=white/dark-gray
        '';
      };
    };
  };
}
