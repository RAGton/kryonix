# Rebuild seguro do Glacier

## Resposta direta

Para fazer rebuild seguro do `glacier`, use o fluxo declarativo do NixOS com `nh os build`, depois `nh os test`, e só depois `nh os switch`.

Rebuild normal do Glacier **não usa ISO live**, **não usa disko**, **não formata disco**, **não reinstala o sistema** e **não monta partição manualmente**.

## Ordem segura

```bash
cd /etc/kryonix

git status --short
git submodule status --recursive

nix flake check -L --show-trace
nh os build .#glacier -L --show-trace

sudo nh os test .#glacier -L --show-trace

# somente após validar
sudo nh os switch .#glacier -L --show-trace
```

## Quando estiver remoto por SSH

Se estiver acessando o Glacier por SSH/Tailscale:

1. prefira `sudo nh os test .#glacier` antes de `switch`;
2. mantenha a sessão SSH aberta durante a validação;
3. confirme que Tailscale e SSH continuam ativos;
4. evite mudar rede, firewall, bootloader, GPU e storage no mesmo rebuild;
5. tenha rollback planejado antes de aplicar permanente.

## Validação antes do switch

```bash
cd /etc/kryonix

git diff --stat
nix flake check -L --show-trace
nh os build .#glacier -L --show-trace
```

## Validação depois do test/switch

```bash
systemctl status sshd.service --no-pager || true
systemctl status tailscaled.service --no-pager || true
systemctl status ollama.service --no-pager || true
systemctl status kryonix-brain-api.service --no-pager || true

kryonix brain cag status
kryonix brain cag route "Como funciona o Glacier no Kryonix?"
kryonix brain search "Como funciona o Glacier no Kryonix?" --explain
```

## Não fazer em rebuild normal

Não faça estes comandos para rebuild comum:

```bash
# NÃO usar para rebuild normal
nixos-install
nixos-generate-config
disko
mkfs
mount /dev/sdX /mnt
./run.sh
```

Também não use:

- ISO live;
- `hosts/glacier/disks.nix`;
- `hosts/glacier/live.nix`;
- `docs/hosts/glacier-live-iso.md`;
- qualquer fluxo de instalação.

Esses arquivos são apenas para instalação, diagnóstico, live ISO ou recuperação específica.

## Riscos

Mudanças que podem quebrar acesso remoto ou boot:

- rede;
- Tailscale;
- firewall;
- SSH;
- bootloader;
- hardware NVIDIA;
- mount/storage;
- `hardware-configuration.nix`;
- `disko`;
- `filesystems`.

Quando mexer em qualquer um desses pontos, use `nh os build` e `nh os test` antes de `switch`.

## Fontes canônicas sugeridas para o CAG

Para perguntas sobre rebuild seguro do Glacier, priorize:

1. `docs/hosts/glacier-rebuild.md`;
2. `docs/hosts/glacier.md`;
3. `.ai/skills/hosts/glacier.md`;
4. `hosts/glacier/default.nix`;
5. `profiles/glacier-ai.nix`;
6. `modules/nixos/services/brain.nix`.

Penalize em pergunta geral:

- `docs/hosts/glacier-live-iso.md`;
- `hosts/glacier/live.nix`;
- `hosts/glacier/disks.nix`;
- arquivos com `disko`, `install`, `format`, `hardware-configuration`.
