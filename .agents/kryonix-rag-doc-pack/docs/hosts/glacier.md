# Host: Glacier

## Papel no Kryonix

`glacier` é o host principal de IA, Brain, Ollama, LightRAG, CAG/RAG, serviços locais e workstation/gaming.

No contexto do Kryonix, `Glacier` significa o host/servidor do projeto, não um glaciar natural.

## Responsabilidades

- rodar Ollama local;
- servir modelos para o Kryonix Brain;
- manter Brain API;
- manter storage do LightRAG/CAG;
- atuar como workstation principal quando necessário;
- manter compatibilidade com gaming sem ocupar VRAM desnecessariamente no boot.

## Arquitetura resumida

```txt
Inspiron
  -> SSH/Tailscale
  -> Glacier
  -> Kryonix Brain API
  -> CAG/RAG
  -> Ollama
  -> Vault/Storage
```

## Serviços importantes

```bash
systemctl status ollama.service --no-pager
systemctl status kryonix-brain-api.service --no-pager || true
kryonix brain cag status
```

## Rebuild seguro

Para rebuild seguro, consulte:

```txt
docs/hosts/glacier-rebuild.md
```

Regra curta:

```bash
cd /etc/kryonix
nix flake check -L --show-trace
nh os build .#glacier -L --show-trace
sudo nh os test .#glacier -L --show-trace
sudo nh os switch .#glacier -L --show-trace
```

## O que evitar em perguntas gerais

Arquivos de ISO, disko, discos, instalação e hardware só são relevantes quando a pergunta mencionar explicitamente:

- ISO live;
- instalação;
- formatação;
- disco;
- particionamento;
- disko;
- hardware;
- filesystem;
- mount.

Em pergunta geral sobre `Como funciona o Glacier`, priorize documentação canônica e configuração ativa.
