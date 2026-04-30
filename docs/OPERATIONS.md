# Operacao do Kryonix

**Atualizado em:** 2026-04-29

## Fluxo oficial

A CLI `kryonix` e o ponto de entrada operacional do projeto. O fluxo oficial e NixOS/Linux, com checkout em `/etc/kryonix` nos hosts instalados.

## Resolucao da flake

A origem da flake segue esta ordem:

1. `--flake <path|uri>` informado no comando
2. variavel de ambiente `KRYONIX_FLAKE`
3. checkout local do Kryonix no diretorio atual ou em algum pai
4. `/etc/kryonix/flake.nix`, quando o sistema ja foi instalado
5. erro com instrucao clara para informar a flake manualmente

## Comandos do dia a dia

```sh
kryonix doctor
kryonix git-status
kryonix check
kryonix fmt
kryonix diff
kryonix test
kryonix boot
kryonix switch
kryonix home
kryonix iso
```

## Brain, Graph, MCP e Vault

Arquitetura oficial:

- `glacier`: servidor central com Ollama, Kryonix Brain, LightRAG storage, MCP Brain, vault e índice.
- `inspiron`: cliente NixOS/workstation. Não exige Ollama, GraphML ou storage local; usa API remota quando `KRYONIX_BRAIN_API` está definido.

No cliente, configure a API remota quando o Glacier estiver disponível:

```sh
export KRYONIX_BRAIN_API=http://glacier:8000
```

Operação no `inspiron`:

```sh
kryonix brain health
kryonix brain stats
kryonix brain search "Como funciona o pipeline RAG do Kryonix?"
kryonix brain ask "pergunta"
kryonix brain doctor --remote

kryonix mcp check
kryonix mcp doctor
kryonix mcp print-config

kryonix test client
kryonix test mcp
```

Operação no `glacier`:

```sh
systemctl status ollama --no-pager
systemctl status kryonix-brain --no-pager
kryonix brain doctor --local
kryonix brain stats --local
kryonix brain storage-check
kryonix brain ollama-check

kryonix graph stats --local
kryonix graph top --local --limit 10
kryonix graph heal --local
kryonix graph repair --local
kryonix test server
```

Validação de build/configuração:

```sh
kryonix vault scan
kryonix vault index
kryonix test all
```

## O que cada comando faz

- `kryonix switch`: aplica a configuracao do host atual com `nh os switch`
- `kryonix boot`: prepara a proxima geracao para o proximo boot
- `kryonix test`: testa a geracao NixOS sem persistir como default
- `kryonix test all`: roda checks de código/configuração, MCP e cliente; runtime remoto vira WARN quando o Glacier estiver offline
- `kryonix test client`: valida CLI/MCP e integração remota se `KRYONIX_BRAIN_API` existir; não exige Ollama/storage local
- `kryonix test server`: valida runtime local do Glacier; exige Ollama, storage e GraphML
- `kryonix test mcp`: valida configuração MCP sem depender de Ollama local
- `kryonix home`: aplica o Home Manager do usuario atual
- `kryonix check`: roda `nix flake check --keep-going`
- `kryonix fmt`: roda o formatter da flake
- `kryonix diff`: compara `/run/current-system` com a proxima geracao
- `kryonix doctor`: mostra host, flake, storage e avaliacao rapida
- `kryonix brain ...`: opera o Brain/LightRAG
- `kryonix graph ...`: opera o grafo do Brain
- `kryonix mcp ...`: valida MCP sem expor secrets

## Definição de pronto

No `inspiron`, a refatoração pode estar pronta em nível de build/configuração quando `check-mcp`, `kryonix mcp check`, `kryonix mcp doctor`, `kryonix test client`, `kryonix test mcp` e `nix flake check` passam. Ausência local de Ollama, GraphML ou storage LightRAG é esperada em cliente.

No `glacier`, pronto em nível de runtime/infra exige `kryonix test server`, `kryonix brain doctor --local`, `kryonix brain stats --local`, `kryonix graph stats --local` e os serviços `ollama` e `kryonix-brain` ativos.

## Fluxo recomendado no `glacier`

1. `kryonix fmt`
2. `kryonix check`
3. `kryonix diff`
4. `kryonix test`
5. `kryonix boot`

Use `kryonix switch` quando a mudanca ja estiver segura para ativacao imediata.

## Observacoes

- fora do checkout local, a CLI usa `/etc/kryonix` como origem padrao instalada
- `/etc/kryonix` deve ser um checkout Git em `main` com `origin`
- `kryonix git-status` e o preflight rapido antes de aplicar mudancas
- `kryonix pull`, `kryonix deploy` e `kryonix sync` abortam em Git quebrado ou flake invalida
