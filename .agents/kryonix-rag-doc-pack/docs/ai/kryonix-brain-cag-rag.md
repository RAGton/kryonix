# Kryonix Brain: CAG + RAG

## Diferença prática

CAG é usado para conhecimento canônico, pequeno, rápido e estável.

RAG é usado para busca ampla, vault grande, histórico, logs, documentos antigos e recuperação semântica.

## Quando usar CAG

Use CAG para:

- comandos canônicos;
- arquitetura do Kryonix;
- papel dos hosts;
- rebuild seguro;
- regras do projeto;
- paths oficiais;
- decisões operacionais estáveis.

## Quando usar RAG

Use RAG para:

- notas antigas;
- busca no vault;
- logs;
- histórico grande;
- documentos específicos;
- perguntas onde o contexto não está no pack canônico.

## Fluxo correto do `kryonix brain search`

```txt
query
  -> CAG route primeiro
  -> se for canônico: CAG
  -> se for busca ampla: RAG/HYBRID
  -> se RAG storage vazio: erro claro ou fallback CAG
```

## Regra anti-alucinação

Se a query contém `Kryonix` e `Glacier`, `Glacier` é host do Kryonix.

Termos proibidos nesse contexto:

- climate change;
- ice sheet;
- ice cores;
- glacial melt;
- geological history;
- polar regions.
