{ pkgs, nhModules, lib, ... }:
{
  imports = [
    "${nhModules}/common"
    "${nhModules}/desktop/kde"
  ];

  # Habilita home-manager
  programs.home-manager.enable = true;

  # Nota: GameMode é instalado aqui como pacote; ativar serviços de sistema
  # (daemons) deve ser feito na configuração do host (NixOS).

  # Pacotes de jogos (ambiente do usuário). Drivers e ajustes de kernel/performance
  # no nível do sistema são responsabilidade da configuração do host (NixOS).
  home.packages = with pkgs; [
    steam
    gamemode
    atlauncher
  ];

  # (sem opção extra de backup aqui; mantenha o controle via `home.file`)

  # A configuração do Zsh (incluindo Powerlevel10k) é centralizada em
  # modules/home-manager/programs/zsh.

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
