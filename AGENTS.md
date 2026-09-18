# 🤖 Diretrizes de Governança e Arquitetura para Agentes de IA

Este é o documento único de referência para assistentes de IA (Antigravity, Codex, Claude, Gemini, etc.) que operam neste repositório.

---

## 🎯 Arquitetura Dual-Flake

1. **Este repositório (`kryonix`) é o MOTOR (Upstream):**
   - Fornece módulos NixOS (`modules/nixos`), Home Manager (`modules/home-manager`), perfis (`profiles/`), pacotes (`packages/`), overlays e biblioteca (`lib/`).
   - Deve ser genérico, portável e reutilizável por qualquer máquina ou usuário.
2. **O repositório downstream (`kryonixos`) é a INSTÂNCIA:**
   - Contém hosts físicos reais, hardware específico, partições ativas e identidades de usuários.

---

## 🏗️ Estrutura e Camadas de Responsabilidade

```
kryonix/
├── flake.nix             # Ponto de entrada do Flake
├── flake/                # Roteamento e dados (lib, packages, overlays, checks)
├── hosts/                # Definições base e ISO (common, iso)
├── modules/              # Módulos NixOS, Home Manager e Darwin
├── profiles/             # Perfis modulares reutilizáveis (laptop, dev, gaming...)
├── packages/             # Pacotes e derivações próprias
├── overlays/             # Overlays do Nixpkgs
├── lib/                  # Opções públicas kryonix.* e helpers
├── desktop/              # Configurações de ambientes gráficos (KDE Plasma, Hyprland)
├── docs/                 # Documentação técnica, especificações e histórico
└── scripts/              # Scripts operacionais e de manutenção
```

### 1. Camada de Host (`hosts/`)
- Foco: Hardware, Kernel, Bootloader, Particionamento.
- Regra: Pacotes de usuário ou ferramentas de desenvolvimento pertencem aos perfis (`profiles/`), não aos hosts.

### 2. Camada de Perfis (`profiles/`)
- Foco: Conjuntos lógicos de funcionalidades (ex.: `dev`, `laptop`, `desktop`).
- Regra: O host apenas ativa perfis; a composição das ferramentas vive no perfil.

### 3. Camada de Módulos (`modules/`)
- Foco: Lógica declarativa e opções NixOS / Home Manager.
- Regra: Garanta retrocompatibilidade e use `lib.mkIf` / `lib.mkDefault`.

---

## 🛡️ Regras de Ouro e Boas Práticas

1. **Validação Obrigatória:**
   - Sempre valide sintaxe e avalie toplevels antes de concluir (`nix flake check` ou `nix eval`).
   - Use `--extra-experimental-features "nix-command flakes"`.
2. **Código Ativo > Documentação Legada:**
   - Sempre inspecione o código em execução antes de assumir estados descritos em notas antigas.
3. **Segurança e Segredos:**
   - **NUNCA** comite chaves privadas, tokens ou arquivos de segredos no repositório ou na Nix Store.
   - Use opções do NixOS para apontar caminhos de runtime.
4. **Sem Poluição na Raiz:**
   - Não crie pastas ou arquivos avulsos de rascunho na raiz do repositório.
   - Documentações, notas e especificações devem viver estritamente dentro de `docs/`.
5. **Declaratividade:**
   - Prefira opções customizadas sob o namespace `kryonix.*` (`lib/options.nix`).
