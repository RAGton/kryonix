{
  outputs,
  userConfig,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/aerospace
    ../programs/warp-terminal
    ../programs/albert
    ../programs/atuin
    ../programs/bat
    ../programs/mangohud
    ../programs/zen-browser
    ../programs/btop
    ../programs/fastfetch
    ../programs/fzf
    ../programs/git
    ../programs/go
    ../programs/gpg
    ../programs/k9s
    ../programs/krew
    ../programs/lazygit
    ../programs/neovim
    ../programs/obs-studio
    ../programs/saml2aws
    ../programs/starship
    ../programs/telegram
    ../programs/zellij
    ../programs/zsh
    ../scripts
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Recarrega unidades do systemd de forma suave ao mudar configs
  systemd.user.startServices = "sd-switch";

  # Configuração do Home Manager para o ambiente do usuário
  home = {
    username = "${userConfig.name}";
    homeDirectory =
      if pkgs.stdenv.isDarwin then "/Users/${userConfig.name}" else "/home/${userConfig.name}";
  };

  # Ajustes de sessão (principalmente Electron/VS Code em Wayland)
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    GTK_USE_PORTAL = "1";

    # Kvantum é um estilo de Qt Widgets, não um estilo de Qt Quick.
    # Se Qt Quick Controls tentar carregar "kvantum" como módulo QML,
    # o Plasma quebra (wallpaper/overview) e pode ficar tudo preto.
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";
  };

  # Garante que os pacotes comuns estejam instalados
  home.packages =
    with pkgs;
    [
      awscli2
      dig
      dust
      eza
      fd
      jq
      kubectl
      nh
      openconnect
      pipenv
      podman-compose
      podman-tui
      python3
      ripgrep
      terraform
      vscode	
    ]
    ++ lib.optionals stdenv.isDarwin [
      anki-bin
      colima
      hidden-bar
      mos
      podman
      raycast
    ]
    ++ lib.optionals (!stdenv.isDarwin) [
      anki
      tesseract
      unzip
      wl-clipboard
    ];
}
