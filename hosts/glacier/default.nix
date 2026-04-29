{
  inputs,
  hostname,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    # Hardware AMD + NVIDIA (nixos-hardware)
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-nvidia

    ./hardware-configuration.nix
    ./rve-compat.nix

    # Kernel e rede
    ../../modules/kernel/zen.nix
    ../../modules/virtualization/net-ragthink.nix
  ];

  # =========================
  # PROFILES (Blueprint)
  # =========================
  kryonix.profiles.server-ai.enable = true;
  # Disabled during the initial install to avoid pulling heavy gaming packages
  # such as Lutris while keeping the hardware/session essentials below.
  kryonix.profiles.workstation-gamer.enable = false;

  # Keep the non-gaming parts normally provided by workstation-gamer.
  kryonix.desktop.environment = "hyprland";
  kryonix.shell.caelestia.enable = true;
  kryonix.features.gaming = {
    enable = false;
    steam.enable = false;
    lutris.enable = false;
    heroic.enable = false;
  };

  # Perfis adicionais herdados
  kryonix.profiles.dev.enable = true;
  kryonix.profiles.university.enable = true;
  kryonix.profiles.ti.enable = true;

  # Drivers NVIDIA (RTX 4060)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = lib.mkForce false;
      offload.enable = lib.mkForce false;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Initial install remote-access baseline.
  services.openssh.enable = true;
  services.tailscale.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    tailscale
  ];

  # =========================
  # NETWORK (Fixed IP 10.0.0.2)
  # =========================
  networking = {
    hostName = hostname;
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
    };

    # Configuração de IP estático para o servidor LAN
    interfaces.enp14s0 = {
      # Nome da interface ajustado para o hardware alvo (exemplo)
      ipv4.addresses = [
        {
          address = "10.0.0.2";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "10.0.0.1";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  # =========================
  # BOOT / KERNEL
  # =========================
  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = false;
        efiInstallAsRemovable = true;
      };
      efi = {
        canTouchEfiVariables = lib.mkForce false;
        efiSysMountPoint = "/boot";
      };
    };

    kernelParams = lib.mkAfter [
      "rootflags=subvol=@,compress=zstd,noatime"
    ];

    # Keep NVIDIA in the installed system, but do not embed its modules in the
    # initrd. The glacier ESP is small and early NVIDIA modules make initrd huge.
    initrd.kernelModules = lib.mkForce [ ];
    kernelModules = [ "kvm-amd" ];
    initrd.systemd.enable = true;
  };

  # =========================
  # SYSTEM
  # =========================
  system.stateVersion = "26.05";

  # Branding
  kryonix.branding = {
    enable = true;
    prettyName = "Kryonix Glacier";
    edition = "Server/Workstation";
  };
}
