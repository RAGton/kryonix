# AGENTS.md

## Papel do repositorio

Kryonix e uma plataforma NixOS declarativa para workstation, gaming, virtualizacao, estudo, desenvolvimento e futura ISO instalavel. O repositorio e fonte de verdade para hosts NixOS, perfis Home Manager, modulos, overlays, pacotes e operacao diaria via CLI `kryonix`.

Antes de qualquer mudanca, leia:

1. `docs/ai/PROJECT_CONTEXT.md`
2. `docs/ai/PROJECT_INDEX.md`
3. `context/INDEX.md`
4. o arquivo real que sera alterado

O codigo real sempre prevalece sobre documentacao historica ou notas do vault.

## Fonte de verdade e ordem de contexto

Quando houver conflito:

1. codigo atual vence;
2. `docs/CURRENT_STATE.md` e `context/CURRENT_STATE.md` orientam o estado documental recente;
3. docs antigas em `docs/` podem ser historicas;
4. notas do vault ajudam no estilo e metodo, mas nao substituem o repo.

Ordem recomendada para agentes:

1. `AGENTS.md`
2. `docs/ai/PROJECT_CONTEXT.md`
3. `docs/ai/PROJECT_INDEX.md`
4. `context/INDEX.md`
5. skill relevante em `skills/**`
6. codigo real
7. documentacao oficial atual apenas quando necessario

## Regras principais

- Faca a menor mudanca correta.
- Nao refatore por estetica durante tarefas pequenas.
- Preserve comportamento funcional salvo pedido explicito.
- Nao altere `flake.lock` sem necessidade real.
- Nao execute comandos destrutivos.
- Nao leia diretorios pesados como `.git`, `node_modules`, `dist`, `build`, `target`, `result`, `.direnv`, `vendor` ou caches.
- Em arvore suja, assuma que mudancas existentes sao do usuario e trabalhe ao redor delas.
- Prefira PRs pequenos, revisaveis e com uma finalidade clara.

## Seguranca

- Nunca commite secrets, tokens, chaves privadas, auth keys ou senhas.
- Nunca coloque secrets no Nix store, em logs, em arquivos versionados ou em derivations publicas.
- Trate `/root/tailscale-authkey.secret`, SSH keys, GPG keys, tokens GitHub e credenciais de VPN como sensiveis.
- Nao enfraqueca firewall, auth, permissoes, sandboxing ou isolamento sem registrar motivo e rollback.
- Scripts remotos devem ser inspecionados antes de uso.

## Testes e validacao

Escolha a validacao pelo risco:

- Docs/contexto: revisar Markdown e links basicos.
- Nix formatting: `nix fmt`.
- Avaliacao geral: `nix flake show --all-systems`.
- Baseline CI: `nix flake check --keep-going`.
- Host especifico: build/eval do host afetado antes de aplicar.
- Operacao local: prefira `kryonix test` ou `kryonix boot` antes de `kryonix switch` em mudancas de maior risco.

Nao rode `switch`, `boot`, `test`, `deploy`, `sync`, `format-*`, `install-system`, `disko` ou comandos com `sudo` sem pedido humano claro.

## Arquitetura

- `flake.nix` declara inputs, outputs, hosts, Home Manager, packages, overlays, formatter e checks.
- `hosts/` contem hardware, boot e papel por maquina.
- `hosts/common/` agrega base compartilhada.
- `lib/options.nix` define o namespace publico `kryonix.*` e aliases temporarios `rag.*`.
- `modules/nixos/**` implementa sistema, desktop, servicos, rede, branding e installer.
- `features/**` habilita capacidades opt-in.
- `profiles/**` compoe papeis reutilizaveis.
- `desktop/hyprland/**` concentra a stack desktop real.
- `home/**` contem configuracao Home Manager por usuario/host.
- `packages/kryonix-cli.nix` e a CLI primaria; `packages/ragos-cli.nix` e compatibilidade legada.

## Backend/API

Este repositorio nao e backend/API de produto web. Se alguma API, servico local ou automacao HTTP aparecer no futuro:

- valide entradas na borda;
- documente contrato;
- use logs estruturados sem dados sensiveis;
- trate auth/autorizacao como obrigatorias;
- adicione teste ou comando de validacao.

## Frontend e desktop

Nao ha frontend web tradicional. A experiencia visual real e desktop Linux:

- Hyprland e o desktop ativo.
- Caelestia e o shell/rice principal.
- DMS e legado em transicao e nao deve receber novos acoplamentos.
- Se docs antigas disserem "Celestial Shell", confira o codigo real; o repo atual usa Caelestia.
- Preserve UWSM no caminho de launch de apps.
- Prefira desktop entries validos para apps graficos.
- Nao reintroduza `wofi` sem decisao explicita.
- Ao tocar em UX desktop, valide login/session, launcher, apps graficos e regressao visual basica.

## NixOS, flakes e hosts

- Hosts devem escolher papeis e opcoes; modulos implementam comportamento.
- Evite `mkForce` desnecessario.
- Separe configuracao por host quando envolver hardware, boot, GPU, discos, energia ou rede.
- `glacier` e host principal AMD + NVIDIA para workstation, gaming e VMs.
- No `glacier`, `hosts/glacier/hardware-configuration.nix` e fonte real do host instalado.
- No `glacier`, nao use `disko`, `format-*`, `install-system` nem `hosts/glacier/disks.nix` para mudancas incrementais.
- `hosts/*/disks.nix` e area de alto risco.

## Estilo de codigo

- Use nomes especificos, unicos e faceis de buscar.
- Prefira early return e fluxo simples.
- Mensagens de erro devem incluir valor invalido e formato esperado quando aplicavel.
- Funcoes novas devem ter responsabilidade unica.
- Evite arquivos grandes novos; extraia por responsabilidade quando houver ganho real.
- Comentarios devem explicar motivo, risco ou workaround, nao repetir o codigo.
- Bibliotecas externas ou patches de upstream devem ficar isolados e documentar criterio de remocao.

## Documentacao

- Atualize documentacao minima quando comportamento publico mudar.
- Nao propague claims de arquitetura que o codigo nao entrega.
- Rebaixe docs antigas para historico quando divergirem do estado real.
- Prefira contexto curto em `docs/ai/` e `context/` a textos longos.

## Observabilidade

- Prefira comandos que mostrem diagnostico antes de aplicar mudancas: `kryonix doctor`, `kryonix diff`, `kryonix git-status`.
- Logs nao devem vazar secrets, tokens, paths privados desnecessarios ou dados pessoais.
- Ao corrigir incidente real, registre em `context/INCIDENTS/` quando isso evitar redescoberta futura.

## CI/CD

- CI atual roda `nix flake show --all-systems` e `nix flake check --keep-going`.
- Mantenha a CI simples e reproduzivel.
- Nao adicione secrets em GitHub Actions.
- Use permissoes minimas em workflows.

## Rollback

- Mudancas NixOS devem preservar caminho de rollback por geracao.
- Para mudancas arriscadas, prefira `kryonix boot` ou `kryonix test` antes de `switch`.
- Documente rollback quando alterar boot, discos, rede, desktop session, GPU, firewall, Tailscale, libvirt ou CLI operacional.

## PRs pequenos

Cada PR deve ter:

- objetivo claro;
- escopo estreito;
- comandos de validacao executados ou motivo para nao executar;
- riscos e rollback quando aplicavel;
- documentacao minima atualizada quando comportamento publico mudar.

## Entrega esperada

Ao finalizar uma tarefa, informe:

- status objetivo;
- arquivos alterados;
- o que mudou;
- como validar;
- limitacoes ou pendencias;
- se uma falha era nova, antiga ou causada por ambiente local.

<!-- BEGIN OBSIDIAN_CLI_ENFORCEMENT -->

## Obsidian CLI Brain Enforcement

This project uses an Obsidian vault as the technical brain.

Vault path:

C:\Users\aguia\Documents\kryonix-vault

Before consulting or updating the vault, the agent must read:

docs/ai/OBSIDIAN_CLI_POLICY.md

Before using the vault, the agent must run:

powershell -ExecutionPolicy Bypass -File .\scripts\Require-ObsidianCli.ps1

### Required behavior

- Use Obsidian CLI as the official access gate for the vault.
- Run obsidian help before relying on CLI behavior.
- Do not read the entire vault.
- Start with indexes, MOCs, project notes, playbooks and prompts.
- Do not directly modify Markdown files in the vault unless explicitly approved.
- If Obsidian CLI is unavailable, stop and report the issue.
- If direct filesystem access is required, explain why and write a request to docs/ai/VAULT_ACCESS_REQUEST.md.

### Brain priority

When using the brain, prioritize:

1. current project code
2. current project docs
3. docs/ai/
4. Obsidian vault via CLI
5. official documentation
6. model memory

### Vault update rule

If a vault update is needed but cannot be safely done through Obsidian CLI, write the proposed update to:

docs/ai/VAULT_UPDATE_PROPOSAL.md

Do not directly modify the vault without explicit user approval.

### Required report

Any vault use must report:

- CLI check result
- Obsidian commands used
- notes consulted
- notes created or updated
- reason for each update
- risk
- whether links may need review
- git diff if the vault is versioned

<!-- END OBSIDIAN_CLI_ENFORCEMENT -->
