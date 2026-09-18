{ pkgs, ... }:
{
  # Script de troca de wallpaper via Caelestia (gerencia transição + esquema de cores)
  home.file.".local/bin/kryonix-wallpaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Uso: kryonix-wallpaper [caminho/para/arte.png]
      #      kryonix-wallpaper --random
      #      kryonix-wallpaper --next

      # Diretório de wallpapers. Ordem de prioridade:
      #   1. $KRYONIX_WALLPAPER_DIR (override do usuário)
      #   2. /etc/kryonix/assets/wallpaper (padrão de deploy)
      #   3. Pack oficial do Nix store (fallback garantido)
      WALL_DIR="''${KRYONIX_WALLPAPER_DIR:-/etc/kryonix/assets/wallpaper}"
      if [ ! -d "$WALL_DIR" ]; then
        WALL_DIR="${pkgs.kryonix-wallpapers}/share/wallpapers/kryonix-aurora"
      fi

      set_wall() {
        local img="$1"
        [ -f "$img" ] || { echo "Arquivo não encontrado: $img"; exit 1; }
        caelestia wallpaper -f "$img"
        notify-send "Kryonix Wallpaper" "$(basename "$img")" \
          --icon "image-x-generic" --expire-time 2000
      }

      case "$1" in
        --random|--next)
          caelestia wallpaper -r "$WALL_DIR"
          ;;
        "")
          caelestia wallpaper -r "$WALL_DIR"
          ;;
        *)
          set_wall "$1"
          ;;
      esac
    '';
  };
}
