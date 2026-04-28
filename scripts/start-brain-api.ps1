# Script para iniciar a API do Kryonix Brain no Glacier
# Este script deve ser executado no Glacier (PC Atual)

$RepoRoot = Resolve-Path ".."
$PackageDir = Join-Path $RepoRoot "packages\kryonix-brain-lightrag"

Write-Host "Iniciando Kryonix Brain API..." -ForegroundColor Cyan
Write-Host "Raiz do Repo: $RepoRoot"
Write-Host "Diretório do Pacote: $PackageDir"

# Navega para a raiz do repo para garantir que o uv encontre o contexto correto se necessário
Set-Location $RepoRoot

# Executa o kg-api via uv
uv run --project "$PackageDir" kg-api
