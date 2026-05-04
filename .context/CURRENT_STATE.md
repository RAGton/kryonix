# Current State

- **Fase Atual:** Estabilização de Serviços do Glacier e Brain API.
- **Ambiente:** Linux (Glacier - NixOS Server / Inspiron - Client).
- **Git Status:** Commit de refatoração do Brain concluído.
- **Serviços Críticos:**
    - Ollama: Habilitado no boot (via `ollamaAutoStart`).
    - Brain API / LightRAG: Parametrizados para usar `/var/lib/kryonix/brain/storage` e `/var/lib/kryonix/vault`.
    - Warmup de Modelo: Desacoplado do boot (via `modelWarmupOnBoot = false`).
- **Progresso:** 
    - Migração física dos dados do Vault/Storage para `/var/lib/kryonix` concluída com sucesso.
    - Avaliação do sistema via `nix build` passou.
- **Bloqueios:** Nenhum. Aguardando a execução do `nh os switch` pelo usuário para ativar os serviços do Brain em definitivo.
