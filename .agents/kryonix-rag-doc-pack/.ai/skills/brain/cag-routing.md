# Skill: CAG Routing

## Regra principal

Para pergunta canônica sobre Kryonix, use CAG antes do RAG.

## Estratégias

### CAG

Use quando a pergunta envolver:

- Glacier como host;
- NixOS rebuild;
- serviços do Brain;
- Ollama;
- MCP;
- comandos oficiais;
- arquitetura do Kryonix;
- documentação canônica.

### RAG

Use quando a pergunta envolver:

- notas antigas;
- busca no Vault;
- logs;
- histórico;
- documentos específicos;
- conteúdo que pode não estar no pack CAG.

### HYBRID

Use quando a pergunta pedir regra canônica e também busca ampla.

## Penalidades de ranking

Penalizar em pergunta geral:

- `live-iso`;
- `live.nix`;
- `disks.nix`;
- `disko`;
- `install`;
- `hardware-configuration.nix`;
- `archive`;
- `legacy`.

Permitir esses arquivos quando a query mencionar explicitamente o domínio deles.
