# Hyprland Rice & Shells

Este diretório concentra a configuração visual (rice) do Hyprland para o ecossistema Kryonix.

## 🚀 Shell Principal: Caelestia
**Caelestia** é o shell oficial e ativo do projeto. Ele fornece a experiência desktop completa via QML/C++, incluindo:
- Painel Dinâmico
- Drawer de Aplicativos (Launcher)
- Dashboard e Centro de Controle
- Sistema de Notificações nativo

A configuração é gerenciada de forma modular em `desktop/hyprland/rice/caelestia-config.nix`.

## 📜 Legado: DankMaterialShell (DMS)
DMS foi a base anterior de rice (baseada em Waybar + Rofi + Dunst). Atualmente está em fase de **transição para histórico** e não deve ser usado para novas implementações.

## 🛠️ Ferramentas de Suporte
O sistema utiliza wrappers declarativos em `desktop/hyprland/wrappers.nix` para garantir que atalhos de sistema (brilho, áudio, capturas) funcionem de forma consistente, independente do shell ativo.
