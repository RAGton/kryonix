{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Display — títulos HUD (nome primário: "JetBrainsMono Nerd Font")
    nerd-fonts.jetbrains-mono

    # Display alternativo — CaskaydiaCove (alinhado com fontconfig global em modules/nixos/common)
    nerd-fonts.caskaydia-cove

    # Body / UI — leitura
    ibm-plex

    # Fallback sem-serif limpo
    inter
  ];
}
