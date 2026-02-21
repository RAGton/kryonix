# Variáveis (sobrescreva se necessário)
HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)
HOME_TARGET ?= $(FLAKE)
EXPERIMENTAL ?= --extra-experimental-features "nix-command flakes"

.PHONY: help install-nix install-nix-darwin darwin-rebuild nixos-rebuild \
	home-manager-switch nix-gc flake-update flake-check bootstrap-mac \
	wayland-session-fix wayland-session-test

help:
	@echo "Alvos disponíveis:"
	@echo ""
	@echo "🚀 SOLUÇÃO SESSÃO WAYLAND (inspiron):"
	@echo "  wayland-session-fix  - Reconstroí + reboot (ativa solução)"
	@echo "  wayland-session-test - Valida que sessão Wayland está ativa"
	@echo ""
	@echo "📦 INSTALAÇÃO:"
	@echo "  install-nix          - Instala o gerenciador de pacotes Nix"
	@echo "  install-nix-darwin   - Instala o nix-darwin usando a flake $(FLAKE)"
	@echo "  bootstrap-mac        - Instala Nix e nix-darwin em sequência"
	@echo ""
	@echo "🔨 RECONSTRUÇÃO:"
	@echo "  nixos-rebuild        - Reconstrói a configuração do NixOS"
	@echo "  darwin-rebuild       - Reconstrói a configuração do nix-darwin"
	@echo "  home-manager-switch  - Aplica a configuração do Home Manager"
	@echo ""
	@echo "🛠️  UTILIDADES:"
	@echo "  flake-check          - Verifica a flake por problemas"
	@echo "  flake-update         - Atualiza as entradas (inputs) da flake"
	@echo "  nix-gc               - Executa coleta de lixo do Nix"
	@echo ""
	@echo "💿 LIVE CD (FORMATAÇÃO E INSTALAÇÃO):"
	@echo "  format-full          - Formata TODO o NVMe via disko (PERDE TUDO no NVMe)"
	@echo "  format-system        - Formata apenas o sistema (preserva /home e SDA)"
	@echo "  install-system       - Instala o NixOS no /mnt"

install-nix:
	@echo "Instalando o Nix..."
	@sudo curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
	@echo "Instalação do Nix concluída."

install-nix-darwin:
	@echo "Instalando o nix-darwin..."
	@sudo nix run nix-darwin $(EXPERIMENTAL) -- switch --flake $(FLAKE)
	@echo "Instalação do nix-darwin concluída."

darwin-rebuild:
	@echo "Reconstruindo a configuração do Darwin..."
	@sudo darwin-rebuild switch --flake $(FLAKE)
	@echo "Reconstrução do Darwin concluída."

nixos-rebuild:
	@echo "Reconstruindo a configuração do NixOS..."
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo "Reconstrução do NixOS concluída."

home-manager-switch:
	@echo "Aplicando a configuração do Home Manager..."
	@home-manager switch --flake $(HOME_TARGET)
	@echo "Home Manager aplicado com sucesso."

nix-gc:
	@echo "Coletando lixo do Nix..."
	@nix-collect-garbage -d
	@echo "Coleta de lixo concluída."

flake-update:
	@echo "Atualizando entradas (inputs) da flake..."
	@nix flake update
	@echo "Atualização da flake concluída."

flake-check:
	@echo "Verificando a flake..."
	@nix flake check
	@echo "Verificação da flake concluída."

bootstrap-mac: install-nix install-nix-darwin

# ============================================================================
# LIVE CD: FORMATAÇÃO E INSTALAÇÃO (Host inspiron)
# ============================================================================

format-full:
	@echo "⚠️  ATENÇÃO: Isso vai APAGAR TUDO no NVMe (incluindo /home)!"
	@echo "Pressione Ctrl+C em 5 segundos para cancelar..."
	@sleep 5
	@echo "Formatando NVMe via disko..."
	@sudo nix run github:nix-community/disko -- --mode disko ./hosts/inspiron/disks.nix
	@echo "Montando SDA (RAG-DATA)..."
	@sudo mkdir -p /mnt/RAG-DATA
	@sudo mount /dev/disk/by-id/ata-KINGSTON_SA400S37240G_50026B7785682AEA-part1 /mnt/RAG-DATA
	@echo "✅ Formatação completa concluída! Agora execute: make install-system"

format-system:
	@echo "⚠️  ATENÇÃO: Isso vai formatar o SISTEMA (p1, p2, p3), mas PRESERVAR o /home (p4) e SDA!"
	@echo "Pressione Ctrl+C em 5 segundos para cancelar..."
	@sleep 5
	@echo "Formatando EFI (p1)..."
	@sudo mkfs.vfat -F32 /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part1
	@echo "Formatando Swap (p2)..."
	@sudo mkswap /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part2
	@sudo swapon /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part2
	@echo "Formatando Sistema btrfs (p3)..."
	@sudo mkfs.btrfs -f -L NIXOS-SYSTEM /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3
	@echo "Criando subvolumes..."
	@sudo mount /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt
	@sudo btrfs subvol create /mnt/@
	@sudo btrfs subvol create /mnt/@nix
	@sudo btrfs subvol create /mnt/@log
	@sudo btrfs subvol create /mnt/@cache
	@sudo btrfs subvol create /mnt/@containers
	@sudo btrfs subvol create /mnt/@libvirt
	@sudo btrfs subvol create /mnt/@snapshots
	@sudo btrfs subvol create /mnt/@persist
	@sudo btrfs subvol create /mnt/@tmp
	@sudo umount /mnt
	@echo "Montando tudo..."
	@sudo mount -o subvol=@,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt
	@sudo mkdir -p /mnt/{boot,home,nix,var/log,var/cache,var/lib/containers,var/lib/libvirt,.snapshots,persist,tmp,RAG-DATA}
	@sudo mount /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part1 /mnt/boot
	@sudo mount -o subvol=@home,compress=zstd,noatime,autodefrag /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part4 /mnt/home
	@sudo mount -o subvol=@nix,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/nix
	@sudo mount -o subvol=@log,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/var/log
	@sudo mount -o subvol=@cache,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/var/cache
	@sudo mount -o subvol=@containers,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/var/lib/containers
	@sudo mount -o subvol=@libvirt,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/var/lib/libvirt
	@sudo mount -o subvol=@snapshots,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/.snapshots
	@sudo mount -o subvol=@persist,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/persist
	@sudo mount -o subvol=@tmp,compress=zstd,noatime /dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_DM382UX7D58F-part3 /mnt/tmp
	@sudo mount /dev/disk/by-id/ata-KINGSTON_SA400S37240G_50026B7785682AEA-part1 /mnt/RAG-DATA
	@echo "✅ Formatação do sistema concluída! Agora execute: make install-system"

install-system:
	@echo "Instalando o NixOS no /mnt..."
	@sudo nixos-install --root /mnt --flake .#inspiron --no-root-passwd
	@echo "Definindo senha do usuário 'rocha'..."
	@sudo nixos-enter --root /mnt -c 'passwd rocha'
	@echo "✅ Instalação concluída! Você pode reiniciar o sistema com: sudo reboot"

# ============================================================================
# SOLUÇÃO: Sessão Wayland com Seat (Host inspiron)
# ============================================================================

wayland-session-fix:
	@echo "🚀 Ativando solução: Sessão Wayland com Seat"
	@echo ""
	@echo "Passo 1: Reconstruindo NixOS (inspiron)..."
	@sudo nixos-rebuild switch --flake .#inspiron
	@echo ""
	@echo "✅ Reconstrução concluída!"
	@echo ""
	@echo "Passo 2: Fazendo reboot..."
	@echo "⚠️  O sistema será reiniciado. Faça login após reboot."
	@echo ""
	@sleep 3
	@sudo reboot

wayland-session-test:
	@echo "🧪 Validando sessão Wayland..."
	@echo ""
	@echo "Verificando tipo de sessão logind:"
	@loginctl session-status
	@echo ""
	@echo "Verificando variáveis de ambiente:"
	@env | grep -E "XDG_SESSION|WAYLAND_DISPLAY" || echo "(Nenhuma variável Wayland encontrada - pode estar em TTY)"
	@echo ""
	@echo "Checklist de sucesso:"
	@echo "  ✓ Type: wayland (não 'tty')"
	@echo "  ✓ Class: user (não 'manager')"
	@echo "  ✓ Seat: seat0 (não vazio)"
