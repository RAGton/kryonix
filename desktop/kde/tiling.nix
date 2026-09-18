# =============================================================================
# desktop/kde/tiling.nix — Tiling (Polonium) + desktops virtuais + scratchpad
#
# O que é:
# - Habilita o KWin/Script Polonium (zeroxoneafour/polonium) de forma declarativa
#   via plasma-manager (`programs.plasma.kwin.scripts.polonium`) e define 10
#   desktops virtuais nomeados (o 10º é o "Scratchpad").
# - Polonium é o substituto moderno do Krohnkite (legado, instável em Plasma 6)
#   e tem suporte first-class no plasma-manager.
#
# Por quê:
# - Krohnkite não tem suporte first-class em plasma-manager — exigia fallback
#   declarativo via kwinrc manual. Polonium tem `programs.plasma.kwin.scripts.polonium.*`
#   com tipos Nix apropriados, validação e merge automático com kwinrc.
#
# Como:
# - programs.plasma.kwin.scripts.polonium.enable = true → escreve
#   [Plugins] poloniumEnabled=true e [Script-polonium] com as settings.
# - programs.plasma.kwin.virtualDesktops cria os 10 desktops (kwinrc [Desktops]).
# - programs.plasma.kwin.borderlessMaximizedWindows melhora a integração.
# - borderless removido do polonium config (polonium tem borderVisibility nativo)
#   — antes era window-rule "no border" agressiva que impedia arrastar janelas.
#
# Riscos:
# - Polonium é Wayland-only (oficial). Hosts em X11 vão carregar mas não tilar.
# - Requer KWin 6.4+ (Plasma 6.4+).
# =============================================================================
{ ... }:
{
  programs.plasma = {
    kwin = {
      # Janelas maximizadas sem borda (melhor integração com tiling).
      borderlessMaximizedWindows = true;

      # Convenção Kryonix: 10 desktops virtuais nomeados (scratchpad fica
      # no desktop 10 e é ativado por atalho separado).
      virtualDesktops = {
        number = 10;
        rows = 1;
        names = [
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "10"
        ];
      };
    };

    # Polonium via plasma-manager (first-class) — substitui a config manual
    # via kwinrc que era usada para o Krohnkite.
    #
    # Settings alinhadas com a paleta/identidade Kryonix:
    #   - engine: half (master-stack clássico; bom default).
    #   - borderVisibility: noBorderTiled (bordas só em janelas flutuantes —
    #     melhor UX que noBorderAll que quebra arrastar).
    #   - filter.processes: processos que não devem ser tilados (system UI).
    #   - tilePopups: false (popups ficam flutuantes, como Breeze).
    kwin.scripts.polonium = {
      enable = true;

      settings = {
        # Estilo de tiling — "half" = master-stack (familiar p/ Hyprland/Sway users).
        layout.engine = "half";
        layout.insertionPoint = "right";
        layout.rotate = false;

        # Bordas nativas do polonium (substitui window-rule noborder antiga).
        borderVisibility = "noBorderTiled";

        # Comportamento.
        maximizeSingleWindow = false;
        resizeAmount = 30;
        callbackDelay = 10;
        saveOnTileEdit = true;
        tilePopups = false;
        enableDebug = false;

        # Filtros (processos que ficam flutuantes — system UI do KDE).
        filter.processes = [
          "krunner"
          "yakuake"
          "kded"
          "polkit"
          "plasmashell"
          "xwaylandvideobridge"
        ];
        filter.windowTitles = [ ];
      };
    };
  };
}
