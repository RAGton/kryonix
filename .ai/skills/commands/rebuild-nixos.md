# Rebuild NixOS Command Skill
O comando correto em sistemas Kryonix (como o Glacier) para reconstrução é sempre usar `nh`.
```bash
nix flake check -L --show-trace
nh os build .#<host> -L --show-trace
sudo nh os test .#<host> -L --show-trace
sudo nh os switch .#<host> -L --show-trace
```
Sem ISO, sem disko, sem scripts ./run.sh manuais.
