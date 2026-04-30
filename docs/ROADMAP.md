# Roadmap do Kryonix

**Atualizado em:** 2026-04-29

## Direção

O roadmap atual é de **consolidação arquitetural e maturidade operacional**. A prioridade é fazer o Kryonix funcionar como plataforma NixOS/Linux real, sem abrir novas frentes frágeis.

## Fase 0 — base operacional

- manter `glacier` avaliando
- manter `hardware-configuration.nix` como verdade local do host principal
- não usar fluxos destrutivos no host instalado
- consolidar a CLI `kryonix` como entrada padrão única

## Fase 1 — documentação canônica

- promover `docs/CURRENT_STATE.md` a referência principal
- manter `docs/INDEX.md` como hub claro para humanos e IAs
- rebaixar documentos antigos para histórico quando não refletirem o estado atual
- resumir `docs/STATUS.md` para refletir a fase atual do projeto

## Fase 2 — desktop, rice e features

- assumir explicitamente que o desktop atual é `hyprland`
- remover resíduos internos de DMS na seleção de desktop
- separar melhor os conceitos de desktop, rice e feature
- decidir se o suporte DMS legado continua existindo ou é absorvido pelo modelo de rice

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
- manter storage de hypervisor em `/srv/ragenterprise`

## Fase 7 — branding e produto

- consolidar o naming público `Kryonix`
- manter branding consistente em GRUB, Plymouth, GDM e desktop
- organizar assets visuais em caminho canônico
- melhorar a percepção do projeto como sistema operacional pessoal, não como dotfiles

## Fase 8 — checks e qualidade

- manter `nixfmt` verde
- manter `flake check --keep-going` útil como baseline
- reduzir falhas locais não estruturais antes de mudanças maiores
- separar validação cliente/servidor do Brain:
  - `inspiron`: `kryonix test client`, `kryonix test mcp` e integração remota via `KRYONIX_BRAIN_API`
  - `glacier`: `kryonix test server`, Ollama, storage LightRAG, GraphML, Brain API e MCP Brain
- tratar ausência de Glacier/Ollama/índice como `WARN` no cliente, não como bloqueio de build

## Fase 9 — ISO futura

- manter o output `iso` como objetivo de produto
- melhorar o fluxo de build e documentação
- preparar a experiência de instalação sem transformar o projeto em distro genérica

## Resultado esperado

Ao final desse roadmap, o projeto deve ficar:

- mais fiel ao estado real
- mais fácil para humanos manterem
- mais seguro para agentes executarem refactors
- mais previsível em desktop, energia e organização
