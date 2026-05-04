# Skill: Rebuild NixOS seguro

## Fluxo padrão

```bash
cd /etc/kryonix

git status --short
git submodule status --recursive

nix flake check -L --show-trace
nh os build .#glacier -L --show-trace
sudo nh os test .#glacier -L --show-trace
sudo nh os switch .#glacier -L --show-trace
```

## Build

`nh os build` avalia e constrói o sistema sem ativar.

## Test

`sudo nh os test` ativa temporariamente até o próximo boot. É melhor para validar rede, SSH, serviços e desktop antes de tornar permanente.

## Switch

`sudo nh os switch` ativa e registra como geração padrão. Use somente depois do build e test passarem.

## Ambiente remoto

Em SSH remoto:

- prefira `test` antes de `switch`;
- mantenha uma sessão aberta;
- evite alterar rede/firewall/SSH/boot junto com outras mudanças;
- tenha rollback planejado.
