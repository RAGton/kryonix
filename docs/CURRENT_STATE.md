# Estado atual do RagOS VE

**Atualizado em:** 2026-04-20

## Resumo

O `ragos-nixos` já está operando, na prática, como **RagOS VE**: uma plataforma NixOS pessoal para workstation, gaming, virtualização, estudo e desenvolvimento.

A base atual já entrega:

- múltiplos hosts (`inspiron`, `inspiron-nina`, `glacier`, `iso`)
- múltiplos usuários (`rocha`, `nina`)
- namespace `rag.*`
- `hosts/common/default.nix` como agregador compartilhado
- `features/` e `profiles/` reais
- stack principal **Hyprland + DMS**
- CLI operacional `ragos`
- `nixosConfigurations`, `homeConfigurations`, `overlays`, `formatter` e `checks`

## Arquitetura real

### Camadas principais

- `hosts/`: hardware, boot e papel de cada máquina
- `hosts/common/default.nix`: composição compartilhada
- `lib/options.nix`: opções públicas `rag.*`
- `modules/nixos/**`: base, rede, áudio, desktop, serviços, theming
- `features/**`: capacidades opt-in
- `profiles/**`: composição reutilizável por papel
- `desktop/hyprland/**`: stack desktop atual
- `home/**`: perfis Home Manager por usuário/host

## Estado por host

### inspiron

- notebook principal
- Intel
- Hyprland + DMS
- profile de laptop com virtualização e desenvolvimento

### inspiron-nina

- notebook da Nina
- Intel
- Hyprland + DMS
- perfil mais leve

### glacier

- desktop AMD + NVIDIA
- Hyprland + DMS
- host principal para workstation, virtualização e gaming
- storage operacional em `/srv/ragenterprise`

### iso

- saída de instalação/provisionamento

## O que está bom

- a arquitetura pública do flake está clara
- hosts estão mais finos do que em fases antigas
- o namespace `rag.*` já existe e é usado
- o desktop principal já está materializado
- o fluxo operacional já pode convergir para `ragos`
- DMS já está integrado ao lado user-level

## O que ainda precisa de atenção

### 1. Documentação desencontrada

Parte da documentação ainda descreve o projeto como se a arquitetura atual não existisse.

### 2. Home Manager ainda parcialmente v1

Alguns homes ainda importam desktop/rice diretamente, o que impede a consolidação completa do modelo por opções.

### 3. Modelagem DMS ainda confusa

Hoje coexistem conceitos próximos demais:

- `rag.features.dms.enable`
- `rag.rice.*`
- `rag.desktop.environment = "hyprland"`

### 4. Duplicação no stack Hyprland

Wrappers e helpers ainda aparecem em mais de um lugar.

### 5. Módulos grandes

`desktop/hyprland/user.nix` e outros arquivos ainda concentram responsabilidade demais.

### 6. Resíduos de migração

Ainda existem trechos, nomes e documentos legados de uma fase anterior da arquitetura.

### 7. Naming público ainda parcial

O branding público já pode ser tratado como **RagOS VE**, mas o nome do repositório e alguns documentos históricos ainda carregam `ragos-nixos`.

## Decisões atuais

- o desktop real do projeto hoje é `hyprland`
- DMS é tratado como rice/shell, não como desktop separado
- documentação histórica deve continuar existindo, mas claramente marcada como histórica
- notebook principal não deve auto-bloquear nem auto-suspender por padrão
- `glacier` deve ser tratado como host principal para virtualização e gaming
- `RagOS` continua sendo o nome base do sistema; `VE` identifica a edição/workstation atual

## Prioridades imediatas

1. alinhar documentação canônica com o estado real
2. simplificar a modelagem desktop/rice/features
3. reduzir duplicação no stack Hyprland
4. quebrar módulos grandes
5. melhorar energia/idle no notebook principal
6. refinar `glacier` como workstation principal
7. consolidar docs e naming do RagOS VE
