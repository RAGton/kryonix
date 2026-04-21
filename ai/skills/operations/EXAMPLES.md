# Exemplos: Operations

## Validação antes de aplicar

```sh
ragos doctor
ragos diff
ragos test
```

## Quando promover para aplicação direta

```sh
ragos switch
```

## Separar erro novo de erro antigo

- repetir o comando base sem a mudança suspeita quando possível
- comparar a saída atual com o comportamento que já falhava antes
- corrigir primeiro a regressão introduzida nesta rodada
