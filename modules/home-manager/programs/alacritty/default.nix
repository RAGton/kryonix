{ pkgs, ... }:
{
  # Instala o alacritty via módulo do Home Manager
  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        live_config_reload = true;
      };

      terminal = {
        shell.program = "${pkgs.zsh}/bin/zsh";
        shell.args = [
          "-l"
          "-c"
          "zellij"
        ];
      };

      env = {
        TERM = "xterm-256color";
      };

      window = {
        decorations = if pkgs.stdenv.isDarwin then "buttonless" else "full";
        dynamic_title = false;
        dynamic_padding = true;
        dimensions = {
          columns = 170;
          lines = 45;
        };
        padding = {
          x = 5;
          y = 1;
        };
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      keyboard.bindings =
        if pkgs.stdenv.isDarwin then
          [
            {
              key = "Slash";
              mods = "Control";
              chars = ''\u001f'';
            }
          ]
        else
          [ ];

      font = {
        size = if pkgs.stdenv.isDarwin then 15 else 12;
        normal = {
          family = "CaskaydiaCove Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "CaskaydiaCove Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "CaskaydiaCove Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "CaskaydiaCove Nerd Font Mono";
          style = "Italic";
        };
      };

      selection = {
        semantic_escape_chars = '',│`|:"' ()[]{}<>'';
        save_to_clipboard = true;
      };
    };
  };
}
