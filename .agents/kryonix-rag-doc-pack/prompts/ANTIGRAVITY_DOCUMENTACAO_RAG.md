# Prompt para Antigravity — Documentação canônica para RAG/CAG Kryonix

Você está no repositório `/etc/kryonix`.

## Objetivo

Estudar todo o projeto Kryonix e criar documentação canônica para alimentar o CAG/RAG local, reduzindo alucinação e melhorando respostas sobre:

- Glacier;
- rebuild seguro;
- NixOS Flakes;
- Kryonix Brain;
- CAG/RAG;
- Ollama;
- MCP;
- paths oficiais;
- serviços systemd;
- comandos canônicos.

## Regras obrigatórias

1. Leia o projeto antes de modificar.
2. Não rode index/repair/reset.
3. Não rode `nh os switch`.
4. Não altere storage real.
5. Não mexa em secrets.
6. Não coloque `/` em MCP filesystem.
7. Não use ISO live/disko como resposta para rebuild normal.
8. Não invente paths, serviços ou comandos.
9. Faça commits pequenos.
10. Rode validações antes de finalizar.

## Arquivos que devem ser lidos primeiro

```txt
AGENTS.md
.ai/
docs/
hosts/glacier/
profiles/glacier-ai.nix
modules/nixos/services/brain.nix
packages/kryonix-cli.nix
packages/kryonix-brain-lightrag/
.mcp.json
flake.nix
```

## Tarefa

Criar/atualizar documentação canônica:

```txt
docs/hosts/glacier-rebuild.md
docs/hosts/glacier.md
docs/ai/kryonix-brain-cag-rag.md
.ai/skills/hosts/glacier.md
.ai/skills/commands/rebuild-nixos.md
.ai/skills/brain/cag-routing.md
rules/cag-ranking-rules.md
.ai/evals/brain_questions.yaml
```

## Conteúdo obrigatório

### Rebuild seguro do Glacier

Deve conter:

```bash
cd /etc/kryonix
git status --short
git submodule status --recursive
nix flake check -L --show-trace
nh os build .#glacier -L --show-trace
sudo nh os test .#glacier -L --show-trace
sudo nh os switch .#glacier -L --show-trace
```

Deve explicar:

- build não ativa;
- test ativa temporariamente;
- switch torna permanente;
- em SSH remoto, usar test antes de switch;
- validar Tailscale/SSH antes de mudanças de rede;
- não usar ISO live para rebuild normal;
- não usar disko/mkfs/mount manual para rebuild normal.

### CAG/RAG

Explicar:

- CAG para conhecimento canônico;
- RAG para busca ampla/histórico/vault;
- `kryonix brain search` deve usar CAG first;
- RAG vazio não deve inicializar LightRAG e alucinar.

## Validação

Rodar:

```bash
cd /etc/kryonix

git status --short
git diff --stat

export LIGHTRAG_CAG_DIR=/tmp/kryonix-cag-test
export KRYONIX_BRAIN_HOME=/tmp/kryonix-brain-test
export KRYONIX_REPO_ROOT=/etc/kryonix
rm -rf "$LIGHTRAG_CAG_DIR" "$KRYONIX_BRAIN_HOME"
mkdir -p "$LIGHTRAG_CAG_DIR" "$KRYONIX_BRAIN_HOME"

uv run --project packages/kryonix-brain-lightrag rag cag build --profile kryonix-core
kryonix brain cag route "Como faço rebuild seguro do Glacier?"
kryonix brain cag ask "Como faço rebuild seguro do Glacier?"
kryonix brain search "Como faço rebuild seguro do Glacier?" --cag-only
```

## Critério de conclusão

A resposta para `Como faço rebuild seguro do Glacier?` deve conter:

- `nh os build .#glacier`
- `nh os test .#glacier`
- `nh os switch .#glacier`

E não deve conter:

- ISO live;
- disko;
- mkfs;
- mount manual;
- clima/gelo/glaciar.

## Entrega

Mostrar:

1. arquivos criados/alterados;
2. diff --stat;
3. validação do CAG;
4. resposta final do `kryonix brain search`;
5. confirmação de que não vazou secret;
6. próximos passos.
