# Camada de IA do RagOS

Esta pasta organiza o material que orienta agentes e assistentes sobre o estado real do projeto.

Ela serve para:

- concentrar contexto canônico curto
- guardar prompts reutilizáveis
- registrar skills por domínio
- oferecer templates para novos artefatos

## Estrutura

- `context/`: fonte de verdade curta sobre estado atual, hosts e modelo operacional
- `prompts/`: prompts prontos para tarefas recorrentes
- `skills/`: instruções operacionais por área do projeto
- `templates/`: moldes para criar novos prompts, skills e checklists

## Como o Copilot deve usar

Uso incremental e local:

1. ler [INDEX.md](INDEX.md)
2. ler o contexto mínimo em `context/`
3. abrir apenas o prompt e a skill relevantes para a tarefa
4. propor mudanças pequenas, verificáveis e alinhadas ao estado atual

Copilot deve evitar:

- inventar arquitetura paralela
- reabrir decisões já descritas em `context/`
- espalhar regras operacionais em comentários soltos pelo repo

## Como o Codex deve usar depois

Uso mais profundo e orientado a execução:

1. começar por [INDEX.md](INDEX.md)
2. tratar `context/` como base canônica curta
3. usar `skills/` para limitar escopo e validar mudanças
4. usar `prompts/` como ponto de partida para refactors e investigações maiores

Codex deve preferir atualizar este material quando a prática operacional mudar, em vez de deixar contexto importante preso em conversa.
