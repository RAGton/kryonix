# =============================================================================
# desktop/kde/user.nix — Orquestrador KDE Plasma 6 (Home Manager)
#
# Puro roteador de imports do ambiente KDE Plasma 6. Cada camada é
# declarativa via plasma-manager (programs.plasma.*).
#
# Camadas implementadas:
#   default.nix        — base da sessão Plasma/Wayland + pacotes
#   rofi.nix           — launcher Rofi (rofi-wayland)
#   ai-tools.nix       — integrações com ferramentas de IA
#   theme.nix          — camada visual (cursor Bibata, painel floating-island,
#                        Dolphin otimizado, blur, transparência)
#   scheme.nix         — color-scheme "Kryonix Dark" opt-in (tokens próprios)
#   tiling.nix         — Krohnkite (kwinrc), 10 desktops virtuais, scratchpad
#   focus.nix          — Foco-segue-mouse + zero focus-stealing
#   lockscreen.nix     — KScreenLocker Kryonix (wallpaper, autolock, lock on resume)
#   keybinds.nix       — injeção dos atalhos no Plasma (shortcuts/hotkeys/spectacle)
#   keybind-helper.nix — Kryonix Keybind Helper (janela com todos os atalhos)
#   multimonitor.nix   — regras de monitor (krfb, fallback xrandr)
#
# Pendências conhecidas:
#   - keymap.nix existe mas ainda não é importado aqui (camada declarativa única
#     de atalhos planejada; hoje vive dentro de keybinds.nix).
#   - launcher.nix (fuzzel layer-shell) e kvantum.nix (BonaFides + QT_QPA_PLATFORMTHEME)
#     ainda não foram portados para cá. Enquanto isso, QT_QPA_PLATFORMTHEME
#     é forçado para "kde" em default.nix para evitar fallback errado.
# =============================================================================
{ ... }:
{
  imports = [
    ./default.nix
    ./rofi.nix
    ./ai-tools.nix
    ./theme.nix
    ./scheme.nix

    ./tiling.nix
    ./focus.nix
    ./lockscreen.nix
    ./keybinds.nix
    ./keybind-helper.nix
    ./multimonitor.nix
  ];
}
