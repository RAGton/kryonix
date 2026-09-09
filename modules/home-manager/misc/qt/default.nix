{
  config,
  lib,
  pkgs,
  ...
}:
{
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
  };
}
