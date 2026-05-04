# CAG Ranking Rules

## Tiers

### Tier 1 — documentação canônica

- `docs/hosts/`
- `docs/ai/`
- `.ai/skills/`
- `README.md`
- `AGENTS.md`

### Tier 2 — configuração ativa

- `hosts/glacier/default.nix`
- `profiles/glacier-ai.nix`
- `modules/nixos/services/brain.nix`
- `modules/nixos/`
- `profiles/`

### Tier 3 — código geral

- `.nix`
- `.py`
- `.rs`
- `.md`

### Tier 4 — baixo nível/perigoso

- `archive`
- `legacy`
- `context-legacy`
- `live-iso`
- `live.nix`
- `disks.nix`
- `disko`
- `install`
- `hardware-configuration.nix`

## Regra Glacier

Em perguntas gerais sobre Glacier, priorizar documentação canônica e configuração ativa.

Não priorizar ISO/disko/discos/hardware se a pergunta não mencionar explicitamente esse domínio.

## Regra rebuild

Para rebuild seguro, priorizar:

1. `docs/hosts/glacier-rebuild.md`
2. `.ai/skills/commands/rebuild-nixos.md`
3. `.ai/skills/hosts/glacier.md`
4. `docs/hosts/glacier.md`

Resposta deve conter:

- `nh os build`
- `nh os test`
- `nh os switch`

Resposta não deve sugerir ISO live para rebuild normal.
