#+#+#+#+####################################################################
# Home Manager: Wallpaper
# Autor: rag
#
# O que é
# - Define um wallpaper padrão e uma lista (galeria) de wallpapers do usuário.
#
# Por quê
# - Padroniza wallpaper no KDE de forma declarativa.
#
# Como
# - Expõe `options.wallpaper` e `options.wallpapers`.
# - Publica o wallpaper padrão em `~/.config/wallpaper.png`.
# - Publica a galeria em `~/.local/share/wallpaper/*`.
#
# Riscos
# - `wallpapers` com nomes (basename) repetidos vão colidir no destino.
{ lib, config, ... }:

{
  options.wallpaper = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    # Antes: default = ./default.nix; (auto-referência circular — apontava para este próprio arquivo .nix)
    # Agora: null — usuários/hosts devem setar explicitamente.
    default = null;
    description = ''
      Caminho do wallpaper padrão. Quando `null`, nenhum arquivo é escrito
      em `~/.config/wallpaper.png` (útil para hosts que definem wallpaper
      por outros meios — KDE).
    '';
  };

  options.wallpapers = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [ ];
    description = "Lista de wallpapers para instalar em ~/.local/share/wallpaper (galeria).";
  };

  config = {
    # Só escreve o wallpaper padrão quando explicitamente fornecido.
    home.file.".config/wallpaper.png" = lib.mkIf (config.wallpaper != null) {
      source = config.wallpaper;
    };

    # Galeria de wallpapers: adiciona todos os arquivos declarados em `wallpapers`.
    # Obs.: nomes repetidos (mesmo basename) vão colidir.
    xdg.dataFile = lib.listToAttrs (
      map (p: {
        name = "wallpaper/${builtins.baseNameOf p}";
        value.source = p;
      }) config.wallpapers
    );
  };
}
