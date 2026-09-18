# =============================================================================
# packages/kryonix-polonium.nix — Polonium (KWin/Script) para KDE Plasma 6
#
# O que é:
# - Empacota o KWin/Script "Polonium" de zeroxoneafour/polonium como derivação
#   Nix pura, expondo o conteúdo em share/kwin/scripts/polonium/ (layout que o
#   plasma-manager / KWin esperam).
#
# Por quê:
# - Substitui o Krohnkite (legado, instável em Plasma 6) por uma alternativa
#   mantida e com suporte first-class no plasma-manager (programs.plasma.kwin.scripts.polonium).
# - Versão pinada (sem `npm ci` nem `esbuild` no build) — fetch direto do
#   `.kwinscript` oficial publicado em release.
#
# Estrutura do upstream (.kwinscript é um zip com layout padrão KPackage):
#   metadata.json
#   contents/code/main.js
#   contents/code/main.mjs          (bundle esbuild)
#   contents/config/main.xml        (kcfg schema)
#   contents/ui/main.qml            (entry point)
#   contents/ui/{config,dbus,settings,shortcuts}.qml
#
# Ativação no host:
#   programs.plasma.kwin.scripts.polonium.enable = true;  # via tiling.nix
#   environment.systemPackages = [ pkgs.kryonix-polonium ];  # via kde module
#
# DBus saver (opcional):
#   O binário Rust `polonium-saver` (em dbus-saver/ no upstream) persiste
#   layouts por-desktop em ~/.config/polonium.json via DBus. Ainda NÃO temos
#   derivação Nix para ele — exige build do fonte Rust com hashes de Cargo.lock
#   que precisam ser gerados em máquina com Nix. Por enquanto os usuários que
#   quiserem o saver devem compilar manualmente via `cd dbus-saver && cargo
#   install --path .` e instalar o .service em ~/.local/share/dbus-1/services/.
#
# Riscos:
# - R-1: Polonium suporta Wayland APENAS (oficial). Hosts em X11 ficam sem tiling.
# - R-2: Requer KWin 6.4+ (6.7 recomendado). Hosts com Plasma mais antigo quebram.
# - R-3: Build pulado (não roda `npm ci`). Hash do `.kwinscript` fixado garante
#        reprodutibilidade; novas versões exigem bump manual + recálculo de hash.
# =============================================================================
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kryonix-polonium";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/zeroxoneafour/polonium/releases/download/v${finalAttrs.version}/polonium.kwinscript";
    # Hash sha256 do .kwinscript oficial v1.2.1 (26403 bytes).
    # Recalcular com `nix-prefetch-url --unpack <url>` ao bumpar versão.
    sha256 = "sha256-H3zRJtQ0F2H94ODYLydxGAMNw3K3NIJdax7fPUG2vYU=";
  };

  nativeBuildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;

  # O .kwinscript é um ZIP com layout `pkg/` por dentro (convenção upstream).
  # KWin procura por `share/kwin/scripts/polonium/{metadata.json,contents/...}`.
  installPhase = ''
    runHook preInstall

    dest="$out/share/kwin/scripts/polonium"
    mkdir -p "$dest"
    # -o sobrescreve sem prompt; -q silencioso.
    unzip -oq "$src" -d "$dest"
    # Renomeia a pasta `pkg/` interna para a raiz esperada pelo KPackage loader.
    # KWin procura metadata.json direto em share/kwin/scripts/<id>/, não em <id>/pkg/.
    if [ -d "$dest/pkg" ]; then
      mv "$dest/pkg"/* "$dest/"
      rmdir "$dest/pkg"
    fi
    chmod -R u+w "$dest"

    runHook postInstall
  '';

  meta = {
    description = "Polonium autotiling KWin/Script — substituto moderno do Krohnkite para Plasma 6";
    longDescription = ''
      Polonium é um gerenciador de tiling autotile para KDE Plasma 6 (KWin 6.4+).
      Sucessor espiritual do Bismuth/Autotile. Substitui o Krohnkite nesta derivação
      do Kryonix por ser a alternativa com suporte first-class no plasma-manager.
    '';
    homepage = "https://github.com/zeroxoneafour/polonium";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
})
