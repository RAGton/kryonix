# Lockscreen e Temas

O projeto padroniza temas visuais na camada `desktop/kde/theme.nix` e `desktop/kde/lockscreen.nix`.

## KScreenLocker (KDE Plasma 6)
A tela de bloqueio oficial utiliza o **KScreenLocker** do KDE Plasma 6.
A configuração vive em `desktop/kde/lockscreen.nix`:
- Autolock após inatividade e bloqueio imediato ao suspender.
- Wallpaper oficial Kryonix aplicado de forma declarativa via plasma-manager.
- Autenticação injetada via PAM (NixOS Security).

## SDDM (Display Manager)
O **SDDM** é o gerenciador de login gráfico padrão do Kryonix.
- Tema: configurado declarativamente em `modules/nixos/desktop/sddm/default.nix`.
- Suporte a Wayland nativo e autologin opcional.

## Assets Globais
Wallpapers e avatares oficiais vivem empacotados em `kryonix-branding`. O plasma-manager garante que a tela de bloqueio e a área de trabalho compartilhem o visual oficial com coesão.
