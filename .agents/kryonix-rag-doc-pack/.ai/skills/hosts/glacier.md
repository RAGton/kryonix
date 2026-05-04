# Host Skill: Glacier

## Identidade

`glacier` é o host principal do Kryonix para IA local, Brain, Ollama, CAG/RAG, workstation e gaming.

Sempre interpretar `Glacier` como host Kryonix quando a pergunta mencionar:

- Kryonix;
- NixOS;
- Brain;
- Ollama;
- host;
- servidor;
- rebuild;
- CAG/RAG;
- Glacier.

Nunca interpretar como glaciar climático nesse contexto.

## Regras de segurança

- Não sugerir ISO live para rebuild normal.
- Não sugerir disko para patch incremental.
- Não sugerir formatação em rebuild comum.
- Não sugerir `nixos-install` em sistema já instalado.
- Preferir `nh os build`, depois `nh os test`, depois `nh os switch`.
- Se remoto por SSH, validar rede/Tailscale antes de switch.

## Comando canônico de rebuild seguro

```bash
cd /etc/kryonix

git status --short
git submodule status --recursive

nix flake check -L --show-trace
nh os build .#glacier -L --show-trace
sudo nh os test .#glacier -L --show-trace
sudo nh os switch .#glacier -L --show-trace
```

## Fontes canônicas

Prioridade para perguntas sobre Glacier:

1. `docs/hosts/glacier-rebuild.md`
2. `docs/hosts/glacier.md`
3. `.ai/skills/hosts/glacier.md`
4. `hosts/glacier/default.nix`
5. `profiles/glacier-ai.nix`
6. `modules/nixos/services/brain.nix`
