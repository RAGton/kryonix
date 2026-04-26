param(
    [string]$VaultPath = "$env:USERPROFILE\Documents\kryonix-vault"
)

$ErrorActionPreference = "Stop"

Write-Host "Checking Obsidian CLI..." -ForegroundColor Cyan

$obsidianCommand = Get-Command obsidian -ErrorAction SilentlyContinue

if (-not $obsidianCommand) {
    $fallback = Join-Path $env:LOCALAPPDATA "Programs\Obsidian\Obsidian.com"

    if (Test-Path $fallback) {
        Write-Host "obsidian was not found in PATH. Using fallback:" -ForegroundColor Yellow
        Write-Host $fallback -ForegroundColor Yellow
        $obsidianExecutable = $fallback
    }
    else {
        Write-Error @"
Obsidian CLI not found.

Fix:
1. Open Obsidian.
2. Go to Settings -> General.
3. Enable Command line interface.
4. Restart PowerShell.
5. Run: obsidian help

Expected vault:
$VaultPath
"@
        exit 1
    }
}
else {
    $obsidianExecutable = $obsidianCommand.Source
    Write-Host "Found Obsidian CLI:" -ForegroundColor Green
    Write-Host $obsidianExecutable -ForegroundColor Green
}

if (-not (Test-Path $VaultPath)) {
    Write-Error "Vault path not found: $VaultPath"
    exit 2
}

Write-Host "Vault path exists:" -ForegroundColor Green
Write-Host $VaultPath -ForegroundColor Green

& $obsidianExecutable help | Out-Host

if ($LASTEXITCODE -ne 0) {
    Write-Error "Obsidian CLI exists but failed to run help command."
    exit 3
}

Write-Host "Obsidian CLI is available and vault path is valid." -ForegroundColor Green
exit 0
