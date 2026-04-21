# RagOS VE

RagOS VE is the workstation, gaming, and virtualization edition of my personal operating system, **RagOS**.

- Current repository: `RAGton/ragos-nixos`
- Public product name: **RagOS VE**
- Language: English | [PT-BR](README.md)

## What this repo is

This is no longer just a dotfiles repository. It is a declarative NixOS platform built for real daily use, focused on:

- primary workstation
- gaming
- personal virtualization with KVM/libvirt
- study and development
- consistent system branding
- future installable RagOS VE ISOs

## Daily workflow

The standard operational entry point is the `ragos` CLI, available in the system PATH:

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

## Quick start

```sh
git clone https://github.com/RAGton/ragos-nixos ragos-ve
cd ragos-ve
nix flake show --all-systems
nix flake check --keep-going
```

## Main host

`glacier` is the main product host right now:

- AMD + NVIDIA workstation
- gaming machine
- personal hypervisor host
- development and study lab

Its real hardware layout is driven by `hosts/glacier/hardware-configuration.nix`. The host-specific `disks.nix` is reserved for provisioning flows and must not be used destructively on the already installed machine.

## Documentation

- [RagOS VE overview](docs/RAGOS_VE.md)
- [Daily operations and CLI](docs/OPERATIONS.md)
- [Glacier host notes](docs/GLACIER.md)
- [Documentation index](docs/INDEX.md)

## License

MIT. See [LICENSE](LICENSE).
