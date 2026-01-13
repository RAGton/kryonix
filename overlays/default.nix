{ inputs, ... }:
{
  # Quando aplicado, o conjunto estável do nixpkgs (declarado nos inputs da flake)
  # fica acessível via 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # OpenRGB bleeding-edge (git) pinado em um commit.
  openrgb-git = final: prev: {
    openrgb-git = prev.openrgb.overrideAttrs (old: let
      rev = "2a1b7a9e2e58c82cbd1e64131644bc2b208f9ba2";
    in {
      pname = "openrgb";
      version = "git-${builtins.substring 0 8 rev}";
      src = prev.fetchFromGitHub {
        owner = "CalcProgrammer1";
        repo = "OpenRGB";
        inherit rev;
        fetchSubmodules = true;
        hash = "sha256-mpDcFWB41wfjHkMydvJaQlkDXuMMUE1A3F1PO5mweeE=";
      };

      # Patches do nixpkgs podem não aplicar no master atual.
      patches = [ ];

      # Evita falhas de substituição herdadas do nixpkgs (scripts mudam no master).
      postPatch = ''
        patchShebangs scripts/build-udev-rules.sh
      '';

      postInstall = (old.postInstall or "") + ''
        if [ -d "$out/lib/udev/rules.d" ]; then
          for f in "$out"/lib/udev/rules.d/*.rules; do
            [ -e "$f" ] || continue
            substituteInPlace "$f" --replace-warn "/usr/bin/env" "${prev.coreutils}/bin/env"
          done
        fi
      '';
    });
  };

  # Workaround: o DrKonqi aborta ao gerar backtrace quando algum mapeamento ELF
  # no core não tem Build-ID (ex.: libxcb-damage). A gente ignora esses módulos
  # em vez de falhar toda a coleta.
  drkonqi-ignore-missing-buildid = final: prev: {
    kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
      drkonqi = kprev.drkonqi.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.python3 ];
        postPatch = (old.postPatch or "") + ''
          p="src/data/gdb_preamble/preamble.py"
          if [ -f "$p" ]; then
            ${prev.python3}/bin/python - <<'PY'
from pathlib import Path

path = Path("src/data/gdb_preamble/preamble.py")
txt = path.read_text(encoding="utf-8")

old = (
    "    for line in output.splitlines():\n"
    "        image = CoreImage(line)\n"
    "        if image.valid:\n"
    "            core_images.append(image)\n"
)

new = (
    "    for line in output.splitlines():\n"
    "        try:\n"
    "            image = CoreImage(line)\n"
    "        except NoBuildIdException:\n"
    "            # Alguns mapeamentos ELF no core podem não ter Build-ID.\n"
    "            # Não abortar a geração do backtrace por isso.\n"
    "            continue\n"
    "        if image.valid:\n"
    "            core_images.append(image)\n"
)

if old not in txt:
    raise SystemExit("drkonqi-ignore-missing-buildid: snippet não encontrado; o upstream mudou")

path.write_text(txt.replace(old, new, 1), encoding="utf-8")
PY
          fi
        '';
      });
    });
  };
}
