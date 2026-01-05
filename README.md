# Configurações NixOS e nix-darwin das minhas máquinas

Este repositório contém as configurações de NixOS e nix-darwin das minhas máquinas, gerenciadas via [Nix Flakes](https://nixos.wiki/wiki/Flakes).

Idioma: PT-BR (este arquivo) | [English](README-en.md)

## Showcase

### Hyprland

![hyprland](./files/screenshots/hyprland.png)

### KDE

![kde](./files/screenshots/kde.png)

### macOS

![macos](./files/screenshots/mac.png)

## Estrutura

- `flake.nix`: a flake (fonte única de verdade), declarando `inputs` e `outputs` de NixOS, nix-darwin e Home Manager.
- `hosts/`: configuração por máquina (ex.: `inspiron`) — deve conter o mínimo possível (imports + hardware).
- `home/`: configuração por usuário e host (Home Manager).
- `files/`: arquivos auxiliares (scripts, wallpapers, screenshots, avatar etc.).
- `modules/`: módulos reutilizáveis por responsabilidade:
  - `modules/nixos/`: módulos de sistema (Linux).
  - `modules/darwin/`: módulos de sistema (macOS).
  - `modules/home-manager/`: módulos de usuário.
- `overlays/`: overlays Nix.
- `flake.lock`: lockfile para builds reprodutíveis.

### Principais inputs

- **nixpkgs**: aponta para `nixos-unstable` (pacotes mais novos).
- **nixpkgs-stable**: aponta para `nixos-25.11` (base estável).
- **home-manager**: gerencia a configuração do usuário.
- **darwin**: habilita nix-darwin no macOS.
- **hardware**: módulos de hardware do nixos-hardware.
- **catppuccin**: tema global Catppuccin.
- **nix-flatpak**: gerenciamento declarativo de Flatpaks.
- **plasma-manager**: gerenciamento declarativo do KDE Plasma.

## Uso

### Aplicando as configurações (NixOS)

- Sistema:

```sh
sudo nixos-rebuild switch --flake .#inspiron
```

- Usuário (Home Manager):

```sh
home-manager switch --flake .#rag@inspiron
```

### Atalhos via Makefile

O [Makefile](Makefile) oferece alvos prontos (assume que o hostname local bate com o output da flake):

```sh
make nixos-rebuild
make home-manager-switch
make flake-check
make flake-update
```

### Adicionando uma nova máquina com um novo usuário

Para adicionar uma nova máquina com um novo usuário (NixOS ou nix-darwin), siga os passos abaixo:

1. **Atualize o `flake.nix`**:

  a. Adicione o novo usuário ao attribute set `users`:

   ```nix
   users = {
    # Usuários existentes...
     newuser = {
       avatar = ./files/avatar/face;
       email = "newuser@example.com";
      fullName = "Novo Usuário";
       gitKey = "YOUR_GIT_KEY";
       name = "newuser";
     };
   };
   ```

  b. Adicione a nova máquina no conjunto de configurações apropriado:

  Para NixOS:

   ```nix
   nixosConfigurations = {
    # Configurações existentes...
     newmachine = mkNixosConfiguration "newmachine" "newuser";
   };
   ```

  Para nix-darwin:

   ```nix
   darwinConfigurations = {
    # Configurações existentes...
     newmachine = mkDarwinConfiguration "newmachine" "newuser";
   };
   ```

  c. Adicione a configuração do Home Manager:

   ```nix
   homeConfigurations = {
    # Configurações existentes...
     "newuser@newmachine" = mkHomeConfiguration "x86_64-linux" "newuser" "newmachine";
   };
   ```

1. **Crie a configuração do sistema**:

  a. Crie um novo diretório em `hosts/` para a máquina:

   ```sh
   mkdir -p hosts/newmachine
   ```

  b. Crie o `default.nix` nesse diretório:

   ```sh
   touch hosts/newmachine/default.nix
   ```

  c. Adicione a configuração base no `default.nix`:

  Para NixOS:

   ```nix
   { inputs, hostname, nixosModules, ... }:
   {
     imports = [
       inputs.hardware.nixosModules.common-cpu-amd
       ./hardware-configuration.nix
       "${nixosModules}/common"
       "${nixosModules}/desktop/hyprland"
     ];

     networking.hostName = hostname;
   }
   ```

  Para nix-darwin:

   ```nix
   { darwinModules, ... }:
   {
     imports = [
       "${darwinModules}/common"
     ];
    # Adicione configurações específicas da máquina aqui
   }
   ```

  d. Para NixOS, gere o `hardware-configuration.nix`:

   ```sh
   sudo nixos-generate-config --show-hardware-config > hosts/newmachine/hardware-configuration.nix
   ```

1. **Crie a configuração do Home Manager**:

  a. Crie um diretório para a configuração do usuário nesse host:

   ```sh
   mkdir -p home/newuser/newmachine
   touch home/newuser/newmachine/default.nix
   ```

  b. Adicione uma configuração base:

   ```nix
   { nhModules, ... }:
   {
     imports = [
       "${nhModules}/common"
      # Adicione outros módulos do home-manager
     ];
   }
   ```

1. **Build e aplicação das configurações**:

  a. Versione os novos arquivos:

   ```sh
   git add .
   ```

  b. Build e switch para a configuração de sistema:

  Para NixOS:

   ```sh
   sudo nixos-rebuild switch --flake .#newmachine
   ```

  Para nix-darwin (requer Nix e nix-darwin instalados):

   ```sh
   darwin-rebuild switch --flake .#newmachine
   ```

  c. Build e switch para a configuração do Home Manager:

> [!IMPORTANT]
> Em sistemas novos, faça o bootstrap do Home Manager primeiro:

```sh
nix-shell -p home-manager
home-manager switch --flake .#newuser@newmachine
```

Depois desse setup inicial, você pode reconstruir separadamente; o `home-manager` ficará disponível sem passos extras.

## Atualizando a flake

Para atualizar todos os inputs para as versões mais recentes:

```sh
nix flake update
```

## Módulos e configurações

### Módulos de sistema (em `modules/nixos/`)

- **`common`**: configurações comuns (bootloader, rede, PipeWire, fontes e usuário).
- **`desktop/hyprland`**: Hyprland com GDM/Bluetooth e pacotes de suporte.
- **`desktop/kde`**: KDE Plasma com SDDM.
- **`programs/steam`**: Steam no nível do sistema.
- **`services/tlp`**: TLP (gerenciamento de energia em notebooks).

### Módulos Darwin (em `modules/darwin/`)

- **`common`**: configurações comuns do macOS (defaults, remapeamento de teclado e usuário).

### Módulos do Home Manager (em `modules/home-manager/`)

- **`common`**: base do ambiente do usuário, importando a maior parte dos módulos.
- **`desktop/hyprland`**: ajustes do Hyprland (binds e serviços como Waybar e Swaync).
- **`desktop/kde`**: ajustes do KDE Plasma, gerenciados declarativamente com `plasma-manager`.
- **`misc/gtk`**: tema GTK3/4 (ícones Tela, cursor Yaru, fonte Roboto) + Catppuccin.
- **`misc/qt`**: tema Qt via Kvantum + Catppuccin (Linux).
- **`misc/wallpaper`**: define o wallpaper padrão.
- **`misc/xdg`**: diretórios XDG e associações MIME.
- **`programs/aerospace` (Darwin):** gerenciador tiling no macOS com regras/binds.
- **`programs/alacritty`:** terminal acelerado por GPU, com integrações.
- **`programs/albert` (Linux):** launcher e ferramenta de produtividade.
- **`programs/atuin`:** histórico de shell com sync/backup.
- **`programs/bat`:** alternativa ao `cat` com syntax highlighting e integração com Git.
- **`programs/brave`:** navegador com associações MIME via XDG (Linux).
- **`programs/btop`:** monitor de recursos com teclas estilo Vim.
- **`programs/fastfetch`:** ferramenta de informações do sistema (customizada).
- **`programs/fzf`:** fuzzy finder com preview.
- **`programs/git`:** Git com detalhes do usuário, assinatura GPG e `delta`.
- **`programs/go`:** ambiente de desenvolvimento Go.
- **`programs/gpg`:** configuração do GnuPG e agent.
- **`programs/k9s`:** TUI para Kubernetes com hotkeys.
- **`programs/krew`:** gerenciador de plugins do `kubectl`.
- **`programs/lazygit`:** TUI para Git.
- **`programs/neovim`:** Neovim baseado no LazyVim.
- **`programs/obs-studio` (Linux):** gravação/streaming.
- **`programs/saml2aws`:** autenticação AWS via SAML.
- **`programs/starship`:** prompt multi-shell.
- **`programs/swappy` (Linux/Hyprland):** editor de screenshots.
- **`programs/telegram`:** cliente desktop do Telegram.
- **`programs/tmux`:** multiplexador de terminal (neste repo, migrado para zellij).
- **`programs/wofi` (Linux/Hyprland):** launcher para Wayland.
- **`programs/zsh`:** Zsh com aliases, completions e keybindings.
- **`scripts`**: instala scripts utilitários em `~/.local/bin`.
- **`services/cliphist` (Linux/Hyprland):** gerenciador de área de transferência.
- **`services/easyeffects` (Linux):** efeitos de áudio (preset de microfone).
- **`services/flatpak` (Linux):** gerenciamento declarativo de Flatpaks.
- **`services/kanshi` (Linux/Hyprland):** configuração dinâmica de monitores.
- **`services/swaync` (Linux/Hyprland):** daemon de notificações.
- **`services/waybar` (Linux/Hyprland):** barra de status do Wayland.

## Contribuindo

Contribuições são bem-vindas! Se tiver melhorias/sugestões, abra uma issue ou envie um pull request.

## Licença

Este repositório está sob licença MIT. Sinta-se à vontade para usar, modificar e distribuir conforme os termos.
