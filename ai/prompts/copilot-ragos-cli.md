# Copilot RagOS CLI

Você está trabalhando na consolidação da CLI `ragos`.

Foco:

- `doctor`
- `snapshot`
- `generations`
- `rollback`

Direção:

- trate `ragos` como entrypoint principal
- se um subcomando ainda não existir, prefira estender a CLI atual
- preserve o modelo por host e a resolução de flake já existente
- não introduza scripts paralelos para operação diária
- mantenha mensagens de erro curtas e acionáveis

Valide:

- host detectado
- flake resolvida
- comportamento seguro antes de ações reversíveis ou destrutivas
