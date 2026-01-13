# =============================================================================
# Autor: rag
#
# O que é:
# - Módulo Home Manager que instala o `warp-terminal` no perfil do usuário.
#
# Por quê:
# - Garante o binário correto via Nix (reprodutível) sem depender de instalação manual.
#
# Como:
# - Adiciona `pkgs.warp-terminal` em `home.packages`.
#
# Riscos:
# - Em alguns ambientes, Warp pode ter dependências/integrações específicas do sistema.
# =============================================================================
{ pkgs, lib, ... }:
{
  # Instala o pacote `warp-terminal` para garantir o binário correto via Nix.
  home.packages = [ pkgs.warp-terminal ];

  # Nota: não habilitamos `programs.wezterm` aqui porque a escolha foi pelo
  # `warp-terminal`, que já provê seu próprio binário.

}
