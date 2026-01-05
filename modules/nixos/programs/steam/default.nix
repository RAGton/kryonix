{ ... }:
{
  # Configuração do Steam (nível do sistema)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
}
