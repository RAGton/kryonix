{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  qt6,
  jq,
  python3,
}:

let
  icons = fetchFromGitHub {
    owner = "gettbitgirl";
    repo = "Yet-Another-Monochrome-Icon-Set";
    rev = "78561e9088b9884e471f87ac08c82045e30207f5";
    hash = "sha256-AxMm55hGa+p9TahweDy6aDgqk0jUpYn3eC6CkQ1OVMs=";
  };
in
stdenv.mkDerivation rec {
  pname = "caelestia-kde";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "ladybug-me";
    repo = "caelestia-kde";
    rev = "v${version}";
    hash = "sha256-u+KlcJ4iF+hkPhMqO5RTg13uXnv3dczDGfQG0cJK7+Q=";
    fetchSubmodules = false;
  };

  # Prebuilt Qt6.11 shell plugins
  prebuiltShell = fetchurl {
    url = "https://github.com/ladybug-me/caelestia-kde/releases/download/v${version}/caelestia-kde-x86_64-qt6.11.tar.gz";
    sha256 = "04pi1yzs5fwv8bix42pdl3mm6jv8wxyaxdcj35vznhq20nq4525r";
  };

  nativeBuildInputs = [ makeWrapper qt6.wrapQtAppsHook autoPatchelfHook ];
  buildInputs = [ qt6.qtbase stdenv.cc.cc.lib ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/qt6/qml
    mkdir -p $out/lib/caelestia
    mkdir -p $out/bin
    mkdir -p $out/share/plasma/shells/caelestia.desktop
    mkdir -p $out/share/quickshell/caelestia

    # Extract prebuilt shell artifacts
    tar -xzf ${prebuiltShell} -C $TMPDIR
    cp -r $TMPDIR/lib/qt6/qml/* $out/lib/qt6/qml/
    cp -r $TMPDIR/lib/caelestia/* $out/lib/caelestia/
    cp -r $TMPDIR/quickshell/* $out/share/quickshell/

    # Install binaries
    for f in caelestia caelestia-record caelestia-screenshot caelestia-shell-ipc caelestia-color caelestia-update caelestia-check-updates; do
      if [ -f "src/bin/$f" ]; then
        install -m 755 "src/bin/$f" $out/bin/
      fi
    done

    # Color pipeline and matugen
    cp -r src/matugen $out/lib/caelestia/matugen
    cp -r src/schemes $out/lib/caelestia/schemes

    # Icons
    mkdir -p $out/share/quickshell/caelestia/assets/icons/yet-another-monochrome-icon-set
    cp -r src/yet-another-monochrome-icon-set/* $out/share/quickshell/caelestia/assets/icons/yet-another-monochrome-icon-set/

    # Lockscreen greeter
    cp -r src/kde/shells/caelestia.desktop/* $out/share/plasma/shells/caelestia.desktop/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Caelestia KDE Shell replacement";
    homepage = "https://github.com/ladybug-me/caelestia-kde";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
