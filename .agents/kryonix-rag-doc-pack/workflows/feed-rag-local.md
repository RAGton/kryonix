# Workflow: alimentar RAG/CAG local

## 1. Copiar documentação canônica

```bash
cd /etc/kryonix
cp -r /CAMINHO/kryonix-rag-doc-pack/docs .
cp -r /CAMINHO/kryonix-rag-doc-pack/.ai .
cp -r /CAMINHO/kryonix-rag-doc-pack/rules .
```

## 2. Validar diff

```bash
git status --short
git diff --stat
git diff -- docs/hosts/glacier-rebuild.md docs/hosts/glacier.md .ai/skills/hosts/glacier.md
```

## 3. Recriar CAG em /tmp

```bash
export LIGHTRAG_CAG_DIR=/tmp/kryonix-cag-test
export KRYONIX_BRAIN_HOME=/tmp/kryonix-brain-test
export KRYONIX_REPO_ROOT=/etc/kryonix
rm -rf "$LIGHTRAG_CAG_DIR" "$KRYONIX_BRAIN_HOME"
mkdir -p "$LIGHTRAG_CAG_DIR" "$KRYONIX_BRAIN_HOME"

uv run --project packages/kryonix-brain-lightrag rag cag build --profile kryonix-core
```

## 4. Testar perguntas críticas

```bash
kryonix brain cag route "Como faço rebuild seguro do Glacier?"
kryonix brain cag ask "Como faço rebuild seguro do Glacier?"
kryonix brain search "Como faço rebuild seguro do Glacier?" --cag-only
```

## 5. Critérios de sucesso

A resposta precisa conter:

- `nh os build .#glacier`
- `sudo nh os test .#glacier`
- `sudo nh os switch .#glacier`

A resposta não pode sugerir:

- ISO live;
- disko;
- mkfs;
- mount manual;
- `./run.sh`;
- clima/gelo/glaciar.
