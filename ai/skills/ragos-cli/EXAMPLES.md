# Exemplos: RagOS CLI

## Diagnóstico

```sh
ragos doctor
ragos doctor --host glacier --verbose
```

## Consolidação de fluxo

```sh
ragos snapshot
ragos generations
ragos rollback
```

## Direção prática

- se `snapshot`, `generations` ou `rollback` ainda não estiverem expostos, estenda `ragos`
- não introduza aliases soltos ou scripts fora da CLI para cobrir esse mesmo fluxo
