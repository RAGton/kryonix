# check-mcp.ps1 — Validate MCP configuration and server availability (Windows)
# Usage: .\scripts\check-mcp.ps1 [-Verbose]

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$EXIT_CODE = 0

# Color functions
function Write-Header {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
    $script:EXIT_CODE = 1
}

function Write-Verbose-Custom {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "  $Message" -ForegroundColor Gray
    }
}

# Constants
$CONFIG_FILE = ".mcp.json"
$EXAMPLE_FILE = ".mcp.example.json"

# Main checks
Write-Header "MCP Configuration Validation"
Write-Host ""

# 1. Check if .mcp.json or .mcp.example.json exists
if (-not (Test-Path $CONFIG_FILE)) {
    if (Test-Path $EXAMPLE_FILE) {
        Write-Warn ".mcp.json not found (is OK if first time). Use: Copy-Item $EXAMPLE_FILE $CONFIG_FILE"
        Write-Warn "Checking $EXAMPLE_FILE instead for syntax..."
        $CONFIG_FILE = $EXAMPLE_FILE
    }
    else {
        Write-Error-Custom ".mcp.json or $EXAMPLE_FILE not found"
        exit 1
    }
}
else {
    Write-Ok ".mcp.json found"
}

# 2. Check JSON syntax
try {
    $json = Get-Content $CONFIG_FILE -Raw | ConvertFrom-Json
    Write-Ok "JSON syntax valid"
}
catch {
    Write-Error-Custom "Invalid JSON in $CONFIG_FILE`n$($_.Exception.Message)"
    exit 1
}

# 3. Check mcpServers key
if (-not $json.mcpServers) {
    Write-Error-Custom "Missing 'mcpServers' key in $CONFIG_FILE"
    exit 1
}
Write-Ok "mcpServers key present"

# 4. Check each server
Write-Host ""
Write-Header "Server Validation"
Write-Host ""

$servers = $json.mcpServers | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

foreach ($server in $servers) {
    Write-Host -NoNewline "  $server : "

    $serverConfig = $json.mcpServers.$server
    $command = $serverConfig.command
    $args = $serverConfig.args
    $cwd = $serverConfig.cwd

    if (-not $command -or -not $args) {
        Write-Error-Custom "command or args missing for $server"
        continue
    }

    # Check if command exists
    try {
        $null = Get-Command $command -ErrorAction Stop
        Write-Ok "✓"
    }
    catch {
        # Special handling for python
        if ($command -eq "python" -or $command -eq "python3") {
            try {
                $null = Get-Command "python" -ErrorAction Stop
                Write-Ok "✓ ($command available)"
            }
            catch {
                Write-Warn "⚠ ($command not found in PATH; may be OK if installed differently)"
            }
        }
        else {
            Write-Warn "⚠ ($command not in PATH; may be OK if installed differently)"
        }
    }

    # If cwd is specified, check it exists
    if ($cwd) {
        if (-not (Test-Path $cwd -PathType Container)) {
            Write-Error-Custom "  → cwd directory not found: $cwd"
        }
        else {
            Write-Verbose-Custom "  → cwd exists: $cwd"
        }
    }
}

# 5. Call rag mcp-check if available
Write-Host ""
Write-Header "Brain-Specific Validation"
Write-Host ""

try {
    $null = Get-Command "rag" -ErrorAction Stop
    if (rag mcp-check 2>&1) {
        Write-Ok "rag mcp-check passed"
    }
    else {
        Write-Error-Custom "rag mcp-check failed (see above for details)"
    }
}
catch {
    Write-Warn "⚠ rag command not found. Install: cd packages/kryonix-brain-lightrag; uv sync"
}

# 6. Summary
Write-Host ""
Write-Header "Summary"
Write-Host ""

if ($EXIT_CODE -eq 0) {
    Write-Ok "All checks passed!"
    Write-Host "Next: Run 'kryonix mcp check' or 'kryonix mcp doctor' for detailed diagnostics"
}
else {
    Write-Error-Custom "One or more checks failed. See above for details."
    Write-Host "Tips:"
    Write-Host "  1. Ensure paths in .mcp.json are absolute (not relative or ~)"
    Write-Host "  2. Install missing commands (uvx, npx, rag, python)"
    Write-Host "  3. Run 'rag mcp-check' for Brain-specific validation"
}

exit $EXIT_CODE
