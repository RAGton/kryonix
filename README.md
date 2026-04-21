# RagOS VE

RagOS VE é a edição de workstation, gaming e virtualização do meu sistema pessoal **RagOS**.

- Repositório atual: `RAGton/ragos-nixos`
- Posicionamento público: **RagOS VE**
- Idioma: PT-BR | [English](README-en.md)

## O que este projeto é

Este repositório já não é apenas uma coleção de dotfiles. Ele é uma plataforma NixOS declarativa para uso real, com foco em:

- workstation principal
- gaming
- virtualização pessoal com KVM/libvirt
- estudo e desenvolvimento
- branding consistente
- base futura para ISOs instaláveis do RagOS VE

## Estado atual

O flake publica hoje:

- `nixosConfigurations` para `inspiron`, `inspiron-nina`, `glacier` e `iso`
- `homeConfigurations` para `rocha@inspiron`, `rocha@glacier` e `nina@inspiron-nina`
- overlays reutilizáveis
- formatter, checks e pacote `ragos`

O host principal de produto neste momento é o `glacier`, tratado como:

- workstation AMD + NVIDIA
- host gamer
- host de VMs
- laboratório do próprio RagOS VE

## Fluxo diário

O fluxo operacional padrão agora é a CLI `ragos`, instalada no PATH do sistema:

```sh
ragos switch
ragos switch --update
ragos boot --update
ragos home
ragos diff
ragos doctor
ragos check
ragos fmt
ragos iso
```

Ela usa `nh`, `nix`, `nvd` e o hostname atual para reduzir atrito operacional no dia a dia.

## Quick start

Se quiser clonar já com o naming novo:

```sh
git clone https://github.com/RAGton/ragos-nixos ragos-ve
cd ragos-ve
```

Inspecionar a flake:

```sh
nix flake show --all-systems
nix flake check --keep-going
```

Aplicar o host atual:

```sh
ragos switch
```

Aplicar explicitamente um host:

```sh
ragos switch --host glacier
```

## Glacier

O `glacier` usa o `hardware-configuration.nix` restaurado como fonte real de boot, root e home. O `disks.nix` fica reservado para provisionamento e **não** deve ser usado de forma destrutiva no host instalado atual.

Além do storage base, o host mantém um storage operacional para virtualização em:

- `/srv/ragenterprise`
- `/srv/ragenterprise/images`
- `/srv/ragenterprise/iso`
- `/srv/ragenterprise/templates`
- `/srv/ragenterprise/snippets`
- `/srv/ragenterprise/backups`

## Branding

O projeto já padroniza o branding do RagOS no:

- `Plymouth`
- `GRUB`
- `GDM`
- wallpaper do desktop
- `/etc/os-release` e `/etc/issue`

O produto é apresentado publicamente como **RagOS VE**, sem perder a identidade base do sistema `RagOS`.

## Documentação

- [Visão do produto RagOS VE](docs/RAGOS_VE.md)
- [Operação diária e CLI](docs/OPERATIONS.md)
- [Papel do host glacier](docs/GLACIER.md)
- [Índice da documentação](docs/INDEX.md)

## Observações de segurança operacional

- não use `disko`, `format-*` ou `install-system` no `glacier` já instalado
- não trate `hosts/glacier/disks.nix` como verdade do hardware atual
- prefira `ragos test` e `ragos boot` antes de mudanças de maior risco

## Licença

MIT. Veja [LICENSE](LICENSE).
