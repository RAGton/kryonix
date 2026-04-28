# Script para configurar acesso seguro via Tailscale ao Kryonix (Glacier)
# EXECUTE COMO ADMINISTRADOR

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERRO: Este script PRECISA ser executado como ADMINISTRADOR." -ForegroundColor Red
    exit
}

$TailscaleIP = "100.108.71.36"
$TailscaleRange = "100.64.0.0/10"

Write-Host "--- Configurando Acesso Privado Tailscale ---" -ForegroundColor Cyan

# 1. Variáveis de Ambiente
Write-Host "[1/4] Configurando Variáveis de Ambiente..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("OLLAMA_HOST", "0.0.0.0:11434", "Machine")
[Environment]::SetEnvironmentVariable("OLLAMA_ORIGINS", "*", "Machine")

# 2. Hardening do Firewall (Remover regras públicas)
Write-Host "[2/4] Removendo regras de acesso público direto..." -ForegroundColor Yellow
netsh advfirewall firewall delete rule name="Kryonix_Ollama_Public" > $null
netsh advfirewall firewall delete rule name="Kryonix_Brain_API_Public" > $null
netsh advfirewall firewall delete rule name="Kryonix_SSH" > $null
netsh advfirewall firewall delete rule name="Kryonix_RustDesk" > $null
netsh advfirewall firewall delete rule name="Kryonix_RustDesk_UDP" > $null

# 3. Criar Regras Restritas ao Tailscale
Write-Host "[3/4] Criando regras restritas à rede Tailscale ($TailscaleRange)..." -ForegroundColor Yellow

# Ollama
netsh advfirewall firewall add rule name="Kryonix_Ollama_Tailscale" dir=in action=allow protocol=TCP localport=11434 remoteip=$TailscaleRange profile=any
# Brain API
netsh advfirewall firewall add rule name="Kryonix_Brain_API_Tailscale" dir=in action=allow protocol=TCP localport=8000 remoteip=$TailscaleRange profile=any

# 4. Finalização
Write-Host "`n[4/4] Configuração Concluída!" -ForegroundColor Green
Write-Host "OLLAMA e Brain API agora só aceitam conexões vindas da rede Tailscale."
Write-Host "IP do Glacier no Tailscale: $TailscaleIP"
Write-Host "Certifique-se de que o Inspiron também está conectado ao Tailscale."
