{ userConfig, ... }:
{
  # Instala o git via módulo do Home Manager
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = userConfig.email;
        name = userConfig.fullName;
      };
      pull.rebase = "true";
    };
    signing = {
      key = userConfig.gitKey;
      signByDefault = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      keep-plus-minus-markers = true;
      light = false;
      line-numbers = true;
      navigate = true;
      width = 280;
    };
  };

  # Habilita o tema Catppuccin para o git delta
  catppuccin.delta.enable = true;
}
