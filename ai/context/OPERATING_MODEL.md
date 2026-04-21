# Modelo Operacional

## Fluxo base

- desenvolvimento local acontece primeiro no `inspiron`
- máquinas já instaladas usam `/etc/ragos` como origem operacional padrão
- a CLI `ragos` é o entrypoint principal para operação e diagnóstico
- bootstrap e aplicação são orientados por host

## Regras práticas

- preferir mudanças incrementais com validação curta
- usar Copilot para evolução local, diffs pequenos e documentação auxiliar
- reservar refactors mais profundos e consolidações amplas para Codex depois
- manter a operação ancorada no host alvo real, não em abstrações paralelas

## Implicação para IA

- não criar fluxo novo fora de `ragos`
- não assumir que o repo sempre roda a partir do checkout local
- distinguir contexto de desenvolvimento local e contexto de sistema instalado
