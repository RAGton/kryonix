# Roadmap atual

**Atualizado em:** 2026-04-20

## Direção

O roadmap atual é de **consolidação arquitetural**. A prioridade não é abrir novas frentes sem fechar as incoerências existentes.

## Fase 1 — documentação canônica

- promover `docs/CURRENT_STATE.md` a referência principal
- manter `docs/INDEX.md` como hub claro para humanos e IAs
- rebaixar documentos antigos para histórico quando não refletirem o estado atual
- resumir `docs/STATUS.md` para refletir a fase atual do projeto

## Fase 2 — desktop, rice e features

- assumir explicitamente que o desktop atual é `hyprland`
- remover resíduos de `rag.desktop.environment == "dms"`
- separar melhor os conceitos de desktop, rice e feature
- decidir se `rag.features.dms.enable` continua existindo ou é absorvido pelo modelo de rice

## Fase 3 — Home Manager

- reduzir imports diretos de `desktop/hyprland/user.nix` nos homes
- criar caminho mais declarativo para seleção de desktop/rice no lado user-level
- evitar que cada home precise editar detalhes internos do stack desktop

## Fase 4 — Hyprland cleanup

- extrair wrappers duplicados para ponto único
- reduzir sobreposição entre system-level e user-level
- quebrar arquivos grandes em submódulos menores

## Fase 5 — notebook principal

- sem auto-lock
- sem auto-suspend
- tampa e idle tratados de forma declarativa
- lock apenas manual por padrão
- display pode apagar por idle, sem bloquear a sessão

## Fase 6 — glacier

- consolidar `glacier` como host principal para virtualização e gaming
- revisar tuning de KVM/IOMMU
- revisar governadores e política de energia
- revisar stack NVIDIA + Wayland
- garantir ferramentas e defaults adequados para workstation

## Fase 7 — checks e qualidade

- manter `nixfmt` verde
- manter `flake check --keep-going` útil como baseline
- reduzir falhas locais não estruturais antes de mudanças maiores

## Resultado esperado

Ao final desse roadmap, o projeto deve ficar:

- mais fiel ao estado real
- mais fácil para humanos manterem
- mais seguro para agentes executarem refactors
- mais previsível em desktop, energia e organização
