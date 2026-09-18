---
applyTo: "flake.nix,flake.lock,hosts/**/*.nix,hosts/**/*.nix,profiles/**/*.nix,features/**/*.nix,modules/**/*.nix,desktop/**/*.nix,home/**/*.nix,packages/**/*.nix"
---

Mantenha a modelagem do repositório: `hosts/` definem máquina, `profiles/` compõem, `features/` habilitam capacidade e `modules/` implementam base.

Não espalhe lógica de feature dentro de host quando um módulo ou profile já resolve.

KDE Plasma 6 (Wayland) + KWin (tiling Krohnkite) é o ambiente desktop oficial exclusivo.

Em árvore suja, prefira `path:$PWD` nas validações Nix para incluir arquivos ainda não rastreados.

Se tocar host, flake, profile, feature ou desktop, valide com builds reais dos hosts afetados e separe claramente erro antigo de erro novo.

No `glacier`, trate o host como máquina já instalada. Não proponha `disko`, `format-*`, `install-system` ou mudanças destrutivas em storage.
