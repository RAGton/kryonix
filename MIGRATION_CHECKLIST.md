# RagOS Incremental Migration Checklist

**Versão**: v1 → v2  
**Modo**: Migração Incremental (1 step at a time)  
**Data Início**: 2026-02-18

---

## 🎯 Regras Obrigatórias

- [x] **NUNCA** aplicar 2 etapas ao mesmo tempo
- [ ] **SEMPRE** rodar `nix flake check` após mudança
- [ ] **SEMPRE** manter boot funcional (rollback disponível)
- [ ] **SEMPRE** commit após cada etapa bem-sucedida

---

## 📊 Progresso Geral

```
Fase 1: Sistema de Opções      ████░░░░░░░░░░░░░░░░  20% (1/5)
Fase 2: Separar Desktop        ░░░░░░░░░░░░░░░░░░░░   0% (0/4)
Fase 3: Hyprland Funcional     ░░░░░░░░░░░░░░░░░░░░   0% (0/3)
Fase 4: DMS                    ░░░░░░░░░░░░░░░░░░░░   0% (0/5)
Fase 5: Features               ░░░░░░░░░░░░░░░░░░░░   0% (0/3)
Fase 6: Profiles               ░░░░░░░░░░░░░░░░░░░░   0% (0/3)

TOTAL:                         ███░░░░░░░░░░░░░░░░░  13% (1/23)
```

---

## 📋 Fase 1 — Sistema de Opções

### Objetivo
Criar infraestrutura de opções `rag.*` sem quebrar configuração existente.

### Etapas

- [x] **1.1** Criar `lib/default.nix` (helpers)
- [x] **1.2** Criar `lib/options.nix` (definir opções rag.*)
- [ ] **1.3** Modificar `flake.nix` (importar lib/options.nix)
- [ ] **1.4** Testar `nix flake check`
- [ ] **1.5** Commit "feat: add rag.* options infrastructure"

**Status**: 🟡 EM PROGRESSO (Etapa 1.3 aguardando)

---

## 📋 Fase 2 — Separar Desktop

### Objetivo
Separar desktop em system.nix (NixOS) e user.nix (Home Manager).

### Etapas

- [ ] **2.1** Mover `modules/nixos/desktop/kde/default.nix` → `desktop/kde/system.nix`
- [ ] **2.2** Mover `modules/nixos/desktop/hyprland/default.nix` → `desktop/hyprland/system.nix`
- [ ] **2.3** Criar `desktop/kde/user.nix` (mover configs do home-manager)
- [ ] **2.4** Criar `desktop/hyprland/user.nix` (mover configs do home-manager)

**Status**: ⏳ AGUARDANDO (Fase 1 completar)

---

## 📋 Fase 3 — Desktop Manager (Auto-import)

### Objetivo
Criar desktop/manager.nix que auto-importa desktop baseado em opção.

### Etapas

- [ ] **3.1** Criar `desktop/manager.nix`
- [ ] **3.2** Atualizar `flake.nix` para importar desktop/manager
- [ ] **3.3** Hosts passam a usar `rag.desktop.environment` (remover imports diretos)

**Status**: ⏳ AGUARDANDO (Fase 2 completar)

---

## 📋 Fase 4 — Hyprland Moderno

### Objetivo
Atualizar Hyprland para padrões modernos (portal correto).

### Etapas

- [ ] **4.1** Atualizar portal: `xdg-desktop-portal-wlr` → `xdg-desktop-portal-hyprland`
- [ ] **4.2** Verificar dbus/session ok
- [ ] **4.3** Testar GDM session

**Status**: ⏳ AGUARDANDO (Fase 3 completar)

---

## 📋 Fase 5 — DMS (DankMaterialShell)

### Objetivo
Integrar DankMaterialShell como rice do Hyprland.

### Etapas

- [ ] **5.1** Adicionar `inputs.dms` no flake.nix
- [ ] **5.2** Criar `rice/dms/default.nix`
- [ ] **5.3** Link Hyprland configs
- [ ] **5.4** Link Waybar configs
- [ ] **5.5** Link Rofi configs

**Status**: ⏳ AGUARDANDO (Fase 4 completar)

---

## 📋 Fase 6 — Features Modulares

### Objetivo
Mover features para módulos opcionais ativados por opções.

### Etapas

- [ ] **6.1** Criar `features/gaming/default.nix`
- [ ] **6.2** Criar `features/virtualization/default.nix`
- [ ] **6.3** Criar `features/development/default.nix`

**Status**: ⏳ AGUARDANDO (Fase 5 completar)

---

## 📋 Fase 7 — Profiles

### Objetivo
Criar profiles composáveis (desktop, laptop, vm).

### Etapas

- [ ] **7.1** Criar `profiles/desktop.nix`
- [ ] **7.2** Criar `profiles/laptop.nix`
- [ ] **7.3** Criar `profiles/vm.nix`

**Status**: ⏳ AGUARDANDO (Fase 6 completar)

---

## 🔥 Etapa Atual

**Fase 1, Etapa 1.3**: Modificar flake.nix para importar lib/options.nix

**Próximos comandos**:
```bash
# Após modificar flake.nix:
nix flake check
nixos-rebuild dry-build --flake .#Glacier
git add lib/ flake.nix MIGRATION_CHECKLIST.md
git commit -m "feat: add rag.* options infrastructure (Phase 1.1-1.3)"
```

---

## 📝 Notas de Migração

### Etapa 1.1-1.2 (Concluída)
- ✅ Criado `lib/default.nix` com helpers
- ✅ Criado `lib/options.nix` com namespace rag.*
- ✅ Opções definidas mas não usadas ainda (sem quebrar sistema)
- ✅ Warnings informativos adicionados

### Próxima Etapa (1.3)
- Modificar flake.nix para importar lib/options.nix
- Sistema continua usando imports diretos (compatibilidade)
- Opções ficam disponíveis mas opcionais

---

## 🎯 Critérios de Sucesso (Fase 1 completa)

- [ ] `nix flake check` passa sem erros
- [ ] `nixos-rebuild dry-build --flake .#Glacier` funciona
- [ ] `nixos-rebuild dry-build --flake .#inspiron` funciona
- [ ] Sistema atual continua bootando normalmente
- [ ] Opções `rag.*` estão disponíveis (via `nix eval`)

---

## 🔄 Rollback

Se algo der errado:
```bash
# Git
git reset --hard HEAD~1

# NixOS
sudo nixos-rebuild switch --rollback

# Home Manager
home-manager switch --rollback
```

---

**Última atualização**: 2026-02-18 (Etapa 1.1-1.2 concluída)  
**Próximo passo**: Etapa 1.3 (modificar flake.nix)

