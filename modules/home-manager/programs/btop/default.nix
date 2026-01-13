{ ... }:
{
  # Instala o btop via módulo do Home Manager
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
  };
}
