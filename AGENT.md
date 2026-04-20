# AGENT.md

## Objetivo

Manter o repositório coerente com a arquitetura já existente e reduzir dívida técnica sem regressões.

## Fonte de verdade

Use esta ordem:

1. código atual
2. `docs/CURRENT_STATE.md`
3. `README.md`
4. `docs/INDEX.md`
5. documentos históricos

Se documentação antiga divergir do código atual, o código vence.

## Premissas

- o projeto já usa `rag.*`
- `hosts/common/default.nix` é o agregador compartilhado
- `features/` e `profiles/` já existem
- o desktop real hoje é `hyprland`
- DMS é rice/shell sobre Hyprland

## Prioridades

1. alinhar documentação com o estado real
2. remover resquícios de migração antiga
3. reduzir duplicação no stack Hyprland
4. melhorar o lado Home Manager
5. manter notebook sem lock/suspend automático indesejado
6. tratar `glacier` como host principal de virtualização e gaming

## Regras

- não tratar `dms` como desktop separado
- não ampliar enums de desktop sem backend real
- não reintroduzir imports manuais em hosts quando houver opção `rag.*`
- não apagar histórico sem movê-lo para área histórica
- não quebrar outputs públicos do flake

## Fluxo

1. auditar arquivos afetados
2. aplicar mudanças pequenas e coesas
3. atualizar docs canônicas quando necessário
4. formatar e validar
5. commitar com mensagem técnica curta
