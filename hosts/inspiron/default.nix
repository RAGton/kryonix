# Host: inspiron (NixOS)
# Autor: rag
#
# O que é
# - Configuração do sistema para a máquina inspiron (imports + ajustes específicos do host).
#
# Por quê
# - Mantém o host “fino”: hardware + integrações específicas, reaproveitando módulos do repo.
#
# Como
# - Importa nixos-hardware + hardware-configuration.
# - Importa módulos comuns (common/desktop/kernel/virtualização).
#
# Riscos
# - Ajustes de kernel/energia/filesystem podem afetar boot e estabilidade; revisar após upgrades.
{
  inputs,
  hostname,
  nixosModules,
  lib,
  ...
}:
{
  imports = [
    # Hardware
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    # Base do sistema
    "${nixosModules}/common"

    # Desktop
    "${nixosModules}/desktop/kde"

    # Kernel e virtualização
    ../../modules/kernel/zen.nix
    ../../modules/virtualization/kvm.nix
    ../../modules/virtualization/net-ragthink.nix

    # Branding (RagOS)
    "${nixosModules}/branding/ragos"
  ];

  networking.hostName = hostname;

  # =========================
  # MikroTik Winbox
  # =========================
  # O que é
  # - Habilita o Winbox (GUI de gerenciamento MikroTik).
  #
  # Por quê
  # - Facilita administrar RouterOS/SwOS direto do desktop.
  #
  # Como
  # - `programs.winbox.enable = true` instala o Winbox.
  programs.winbox.enable = true;

  # UniFi Network Application (Controller).
  # services.unifi = {
  #   enable = true;
  #   openFirewall = true;
  # };

  system.stateVersion = "25.11";

  # =========================
  # Boot / Kernel
  # =========================
  boot = {
    loader = {
      systemd-boot.enable = false;

      grub = {
	enable = true;
	efiSupport = true;
	device = "nodev";
	useOSProber = true;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    # Kernel params globais.
    kernelParams = [
      "rootflags=subvol=@,compress=zstd,noatime"
    ];

    # Evita builds inúteis
    initrd.systemd.enable = true;
  };

  # =========================
  # Kernel Zen (ajustado)
  # =========================
  kernelZen = {
    enable = true;

    kernel = "zen";
    forceLocalBuild = true;
    useLLVMStdenv = true;
    extraMakeFlags = [
      "KCFLAGS=-march=native"
      "KCPPFLAGS=-march=native"
    ];

    # ⚠️ só recomendo isso se for desktop single-user.
    disableMitigations = lib.mkDefault false;

    extraKernelParams = [
      "sched_latency_ns=4000000"
      "sched_min_granularity_ns=500000"
    ];
  };

  ## -------------------------
  ## Performance básica
  ## -------------------------
  powerManagement.cpuFreqGovernor = "performance";

  # Gaming/stabilidade: evita serviços que brigam por perfil de energia.
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.tlp.enable = lib.mkForce false;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
  '';

  ## -------------------------
  ## Virtualização (ajuste fino)
  ## -------------------------
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
  '';

  # =========================
  # RagOS (branding do sistema)
  # =========================
  # Mantém o mesmo número de versão do seu `system.stateVersion` para exibição.
  # Obs.: `system.stateVersion` continua sendo a chave de compat do NixOS.
  ragos = {
    enable = true;
    prettyName = "RagOS";
    versionId = "25.11";
  };
}
