# Rebuild Seguro do Glacier

Este documento é a fonte canônica para o processo de rebuild e atualização do host Glacier.

## Regras Críticas
Para rebuild do Glacier: NUNCA recomende ISO live, disko, mount manual, mkfs, ./run.sh ou instalação normal.
A resposta não pode conter: climate, ice ou glacial.

## Procedimento Oficial:
```bash
nix flake check -L --show-trace
nh os build .#glacier -L --show-trace
sudo nh os test .#glacier -L --show-trace
sudo nh os switch .#glacier -L --show-trace
```
