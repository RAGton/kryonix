$ErrorActionPreference = "Stop"

Write-Host "Iniciando Kryonix Brain API..."

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$PackageDir = Join-Path $RepoRoot "packages\kryonix-brain-lightrag"

Write-Host "Raiz do Repo: $RepoRoot"
Write-Host "Diretório do Pacote: $PackageDir"

if (-not (Test-Path $PackageDir)) {
    Write-Error "Diretório do pacote não encontrado: $PackageDir"
    exit 1
}

$Key = [Environment]::GetEnvironmentVariable("KRYONIX_BRAIN_KEY", "Machine")
if (-not $Key) {
    Write-Warning "KRYONIX_BRAIN_KEY não está definida no escopo Machine."
    Write-Warning "Defina com: [Environment]::SetEnvironmentVariable('KRYONIX_BRAIN_KEY', '<key>', 'Machine')"
} else {
    $env:KRYONIX_BRAIN_KEY = $Key
}

uv run --project "$PackageDir" kg-api
