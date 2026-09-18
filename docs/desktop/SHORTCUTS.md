# Atalhos Globais (KDE Plasma 6)

Ambiente oficial do Kryonix. Atalhos centralizados em `desktop/kde/keybinds.nix`
(aplicados via plasma-manager: `kglobalshortcutsrc` + `hotkeys.commands`).
O modificador primário é a tecla **Meta/SUPER/WIN**. Tiling gerenciado via **Krohnkite** (KWin).

## Janelas
- `Meta + Q`: Fechar janela.
- `Meta + F`: Fullscreen.
- `Meta + Tab` / `Alt + Tab`: Alternar entre janelas.
- `Meta + W`: Overview · `Meta + G`: Grid View.

## Tiling (Krohnkite)
- `Meta + H/J/K/L`: Mover **foco** (esquerda/baixo/cima/direita).
- `Meta + Shift + H/J/K/L`: **Mover** a janela.
- `Meta + Ctrl + H/J/K/L`: **Redimensionar** a janela.
- `Meta + Space`: Próximo layout · `Meta + Shift + F`: Toggle float.
- Layouts: `Meta + D` (spiral), `Meta + B` (b-tree), `Meta + M` (monocle), `Meta + C` (columns).

## Desktops virtuais (10, o 10º = Scratchpad)
- `Meta + 1..0`: Ir para o desktop N.
- `Meta + Shift + 1..0`: Mover janela para o desktop N.
- `Meta + Ctrl + 1..0`: Mover janela **e seguir** para o desktop N.
- `Meta + S` / `Meta + Shift + S`: Scratchpad (desktop 10).

## Launchers e Apps
- `Meta + A`: Wofi / Rofi (launcher de aplicativos).
- `Meta + T` / `Meta + Return`: Terminal (`warp-terminal`).
- `Meta + Shift + T`: Terminal flutuante.
- `Meta + O`: Dolphin · `Meta + N`: Zen Browser · `Meta + R`: VSCode.
- `Meta + /` ou `Meta + F1`: Kryonix Keybind Helper (lista de atalhos).

## Sessão e mídia
- `Meta + Escape`: Bloquear sessão · `Shift + Escape`: Logout.
- `Meta + Ctrl + Escape`: Reiniciar (com confirmação).
- `Meta + ,` / `Meta + .`: Faixa anterior/próxima · `XF86AudioPlay`: Play/Pause.
- `Print` / `Shift + Print`: Spectacle (tela inteira / região).

> Limitação documentada: `Meta + Scroll` para trocar de desktop não é
> expressável declarativamente nesta rev do plasma-manager (ver nota em
> `desktop/kde/keybinds.nix`).
