#!/usr/bin/env bash
# Script de teste rápido para verificar sintaxe Nix

set -e

echo "🔍 Testando sintaxe dos arquivos modificados..."

echo "1. Desktop Manager..."
nix-instantiate --parse desktop/manager.nix > /dev/null && echo "✅ OK" || echo "❌ ERRO"

echo "2. KDE System..."
nix-instantiate --parse desktop/kde/system.nix > /dev/null && echo "✅ OK" || echo "❌ ERRO"

echo "3. Hyprland System..."
nix-instantiate --parse desktop/hyprland/system.nix > /dev/null && echo "✅ OK" || echo "❌ ERRO"

echo "4. Features Gaming..."
nix-instantiate --parse features/gaming.nix > /dev/null && echo "✅ OK" || echo "❌ ERRO"

echo "5. Features Virtualization..."
nix-instantiate --parse features/virtualization.nix > /dev/null && echo "✅ OK" || echo "❌ ERRO"

echo "6. Features Development..."
nix-instantiate --parse features/development.nix > /dev/null && echo "✅ OK" || echo "❌ ERRO"

echo ""
echo "🧪 Testando avaliação básica..."
timeout 60 nix eval .#nixosConfigurations.inspiron.config.networking.hostName 2>&1 || echo "Timeout ou erro"

echo ""
echo "✨ Testes concluídos!"

