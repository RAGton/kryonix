# Kryonix RAG/CAG Documentation Pack

Pacote de documentação canônica para alimentar o RAG/CAG local do Kryonix.

## Objetivo

Evitar respostas perigosas ou genéricas sobre o projeto, especialmente em temas como:

- rebuild seguro do Glacier;
- papel do host Glacier;
- CAG vs RAG;
- paths oficiais do Brain;
- comandos canônicos do Kryonix;
- regras de ranking e anti-alucinação.

## Como usar

Copie os arquivos para a raiz do repositório Kryonix:

```bash
cd /etc/kryonix
cp -r /CAMINHO/kryonix-rag-doc-pack/docs .
cp -r /CAMINHO/kryonix-rag-doc-pack/.ai .
cp -r /CAMINHO/kryonix-rag-doc-pack/rules .
cp -r /CAMINHO/kryonix-rag-doc-pack/workflows .
```

Depois valide:

```bash
cd /etc/kryonix
git status --short
git diff --stat
```

Recrie o CAG em ambiente controlado:

```bash
export LIGHTRAG_CAG_DIR=/tmp/kryonix-cag-test
export KRYONIX_BRAIN_HOME=/tmp/kryonix-brain-test
export KRYONIX_REPO_ROOT=/etc/kryonix
rm -rf "$LIGHTRAG_CAG_DIR" "$KRYONIX_BRAIN_HOME"
mkdir -p "$LIGHTRAG_CAG_DIR" "$KRYONIX_BRAIN_HOME"

uv run --project packages/kryonix-brain-lightrag rag cag build --profile kryonix-core
kryonix brain cag route "Como faço rebuild seguro do Glacier?"
kryonix brain cag ask "Como faço rebuild seguro do Glacier?"
```

## Regra importante

Rebuild normal do Glacier NÃO usa ISO live, NÃO usa disko, NÃO formata disco e NÃO roda instalação.

A ordem segura é:

```bash
cd /etc/kryonix
git status --short
git submodule status --recursive
nix flake check -L --show-trace
nh os build .#glacier -L --show-trace
sudo nh os test .#glacier -L --show-trace
sudo nh os switch .#glacier -L --show-trace
```
