{
  # Paleta Hyprland alinhada com desktop/branding/kryonix/palette.nix (dark).
  # Mudanças:
  #   - bg0 sincronizado com backgroundDeep da paleta oficial (#0b0f14).
  #   - hud1 mantido como accentCyan oficial (#00d4ff).
  #   - accentBlue oficial (#38bdf8) adicionado como `blue` para uso direto.
  bg0 = "0b0f14"; # fundo principal — espaço profundo (backgroundDeep oficial)
  bg1 = "0f1419"; # superfícies — painéis (backgroundSoft oficial)
  bg2 = "14191e"; # borda interna (surface oficial)
  border = "1e2d3d"; # bordas de janela padrão (borderSubtle oficial)

  # HUD colors — destaque ciano elétrico (accentCyan oficial)
  hud1 = "00d4ff"; # destaque primário (titlebars, borders ativos)
  hud2 = "0099cc"; # destaque secundário (badges, indicadores)
  hud3 = "005580"; # destaque terciário (sombras coloridas)

  # Kryonix Blue (accentBlue oficial)
  blue = "38bdf8"; # azul Kryonix — destaques secundários, links

  # Terminal green — acento
  term1 = "39ff14"; # verde neon — alertas, cursor (success oficial)
  term2 = "00cc00"; # verde médio
  term3 = "004400"; # verde escuro

  # Textos
  fg0 = "e8f4f8"; # texto principal (textPrimary oficial)
  fg1 = "8badbf"; # texto secundário (textMuted oficial)
  fg2 = "4a6b7a"; # texto apagado / comentário

  # Estados
  red = "ff4455";    # danger oficial
  yellow = "ffcc00"; # warning oficial
  purple = "b48eff";
}
