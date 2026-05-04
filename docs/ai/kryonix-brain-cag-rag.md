# Configuração CAG/RAG

Em caso de dúvidas de configuração e operações críticas, a base CAG/RAG não tem permissão de usar respostas que fujam aos documentos oficiais.

Regra crítica para rebuild seguro do Glacier: A resposta não pode conter ISO live, disko, mkfs, mount manual, ./run.sh, climate, ice ou glacial.
Deve usar obrigatoriamente:
- nix flake check -L --show-trace
- nh os build .#glacier -L --show-trace
- sudo nh os test .#glacier -L --show-trace
- sudo nh os switch .#glacier -L --show-trace
