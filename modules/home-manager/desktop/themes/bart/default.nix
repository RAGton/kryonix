# Home Manager: Tema Bart (Plasma + GTK + Ícones)
# Repo: https://gitlab.com/jomada/bart
#
# Objetivo
# - Instalar e aplicar automaticamente o tema Bart no Plasma (plasma-manager)
# - Aplicar tema GTK e ícones (via Home Manager)
#
# Notas
# - Cursor você já gerencia em outro lugar (Nordzy), então não mexemos.
# - O repositório Bart é um conjunto de assets; empacotamos via symlinks.
{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  # Fonte upstream (git)
  src = inputs.bart-theme;

  # Heurísticas (estrutura típica de temas)
  # Sem assumir nomes exatos: instalamos o que existir.
  installIfExists = rel: destRel:
    if builtins.pathExists (src + ("/" + rel)) then
      { name = destRel; value.source = src + ("/" + rel); }
    else
      null;

  # Tentativas comuns: Plasma Look-and-Feel / plasma theme / color schemes / icons / GTK / Kvantum / Aurorae
  candidates = lib.filter (x: x != null) [
    (installIfExists "plasma" "plasma")
    (installIfExists "Plasma" "plasma")

    (installIfExists "look-and-feel" "plasma/look-and-feel")
    (installIfExists "Look-and-Feel" "plasma/look-and-feel")

    (installIfExists "color-schemes" "color-schemes")
    (installIfExists "colorschemes" "color-schemes")
    (installIfExists "color_schemes" "color-schemes")

    (installIfExists "icons" "icons")
    (installIfExists "Icons" "icons")

    (installIfExists "gtk" "themes")
    (installIfExists "GTK" "themes")
    (installIfExists "themes" "themes")

    (installIfExists "kvantum" "Kvantum")
    (installIfExists "Kvantum" "Kvantum")

    (installIfExists "aurorae" "aurorae/themes")
    (installIfExists "Aurorae" "aurorae/themes")
    (installIfExists "window-decorations" "aurorae/themes")
    (installIfExists "Window-Decorations" "aurorae/themes")
  ];

  # Converte em xdg.dataFile attrs (aponta pra ~/.local/share)
  dataFiles =
    lib.listToAttrs (
      map (x: {
        name = x.name;
        value = {
          source = x.value.source;
          recursive = true;
        };
      }) candidates
    );

  # Nome do tema: pode variar (Bart, Bart-dark, etc.).
  # Vamos permitir override futuro via option, mas default = "Bart".
  cfg = config.rag.theme.bart;

in
{
  options.rag.theme.bart = {
    enable = lib.mkEnableOption "Tema Bart (Plasma + GTK + Ícones)";

    # Nome a ser aplicado no Plasma/GTK/ícones.
    # Se o upstream usar outro nome, você pode ajustar no host sem mexer no módulo.
    name = lib.mkOption {
      type = lib.types.str;
      default = "Bart";
      description = "Nome do tema Bart conforme aparece no Plasma/GTK (ex.: Bart, Bart-Dark).";
    };

    iconName = lib.mkOption {
      type = lib.types.str;
      default = "Bart";
      description = "Nome do tema de ícones Bart, se existir (senão, ajuste aqui).";
    };

    gtkName = lib.mkOption {
      type = lib.types.str;
      default = "Bart";
      description = "Nome do tema GTK Bart, se existir (senão, ajuste aqui).";
    };

    kvantumTheme = lib.mkOption {
      type = lib.types.str;
      default = "Bart";
      description = "Nome do tema Kvantum Bart.";
    };

    auroraeTheme = lib.mkOption {
      type = lib.types.str;
      default = "__aurorae__svg__Bart";
      description = "Nome do tema Aurorae (decoração de janelas) Bart.";
    };

    # Por padrão NÃO aplicamos look-and-feel automaticamente porque ele pode sobrescrever
    # windowDecorations/splashScreen e gerar warning no plasma-manager.
    plasmaLookAndFeel = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "Bart";
      description = "Look-and-feel do Plasma para aplicar (null para não aplicar).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Instala assets do tema em ~/.local/share para o Plasma/GTK detectar.
    xdg.dataFile = dataFiles;

    # GTK
    gtk = {
      enable = true;
      theme = {
        name = cfg.gtkName;
      };
      iconTheme = {
        name = cfg.iconName;
      };

      # Você já pode ter arquivos existentes de tema GTK (de setups antigos/manuais).
      # Forçamos o overwrite para manter estado 100% declarativo e evitar falha no switch.
      gtk3.extraConfig = lib.mkForce { };
      gtk4.extraConfig = lib.mkForce { };

      # GTK2 está em EOL e costuma ser só fonte de conflito (.gtkrc-2.0).
      # Desabilitamos a geração do gtk2 para evitar colisões e manter switch robusto.
      gtk2.enable = lib.mkForce false;
    };

    # Arquivos GTK que o HM escreve e que normalmente conflitam com configs antigas.
    # `force = true` resolve o erro "would be clobbered".
    xdg.configFile."gtk-3.0/settings.ini".force = true;
    xdg.configFile."gtk-4.0/settings.ini".force = true;

    # Kvantum theme configuration
    xdg.configFile."Kvantum/kvantum.kvconfig" = {
      force = true;
      text = lib.generators.toINI { } {
        General = {
          theme = cfg.kvantumTheme;
        };
      };
    };

    # Plasma (plasma-manager)
    programs.plasma = {
      # não setamos enable aqui pra não forçar; o módulo kde já faz isso
      workspace = {
        lookAndFeel = lib.mkIf (cfg.plasmaLookAndFeel != null) cfg.plasmaLookAndFeel;
        iconTheme = cfg.iconName;

        # Aurorae (decoração de janelas)
        windowDecorations = {
          library = "org.kde.kwin.aurorae";
          theme = cfg.auroraeTheme;
        };
      };

      # Alguns setups usam colorscheme separado do lookandfeel.
      # Se o tema expor um colorscheme com o mesmo nome, o Plasma aplica.
      # Se não existir, ele mantém o atual.
      workspace.colorScheme = lib.mkDefault cfg.name;
      workspace.theme = lib.mkDefault cfg.name;
    };
  };
}

