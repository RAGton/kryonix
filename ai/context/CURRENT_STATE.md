# Estado Atual

O projeto já opera como uma base NixOS multi-host com arquitetura pública centrada em `rag.*`.

Pontos principais:

- hosts ativos: `inspiron`, `inspiron-nina`, `glacier` e `iso`
- `glacier` é o host principal de produto e operação
- `inspiron` é o ambiente principal de desenvolvimento local
- a CLI `ragos` é o entrypoint operacional já visível no repo
- o foco atual é consolidar CLI e operação antes de abrir refactors maiores

Leitura prática do momento:

- manter a arquitetura existente
- reduzir atrito operacional
- tratar contexto e docs como apoio à manutenção real do RagOS
