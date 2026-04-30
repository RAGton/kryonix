#!/bin/bash
# check-mcp.sh — Validate MCP configuration and server availability
# Usage: ./scripts/check-mcp.sh [--verbose]

set -euo pipefail

VERBOSE=${1:-}
CONFIG_FILE=".mcp.json"
EXAMPLE_FILE=".mcp.example.json"
EXIT_CODE=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
  echo -e "${BLUE}→ $1${NC}"
}

print_ok() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_warn() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
  EXIT_CODE=1
}

verbose() {
  if [[ -n "$VERBOSE" ]]; then
    echo "  $1"
  fi
}

# Helper: parse JSON with jq or python fallback
parse_json() {
  local file=$1
  local query=$2
  if command -v jq &> /dev/null; then
    jq -r "$query" < "$file"
  else
    python3 -c "import json, sys; d = json.load(open('$file')); print($query.replace('.', \"['\")+\".replace('\"','\"']+\"']\")" 2>/dev/null || true
  fi
}

# Validate no dangerous paths or secrets
validate_security() {
  local file=$1
  local config
  config=$(cat "$file" 2>/dev/null || echo "{}")

  # Reject filesystem path exactly "/"
  if echo "$config" | grep -q '"args":\s*\[.*"/"'; then
    print_error "Filesystem MCP cannot be mounted at root (/)"
    return 1
  fi

  # Reject critical system paths
  for dangerous_path in "/root" "/etc" "/boot" "/nix/store" "/var" "/sys" "/proc" "/dev"; do
    if echo "$config" | grep -q "\"$dangerous_path\""; then
      print_error "Dangerous filesystem path detected: $dangerous_path"
      return 1
    fi
  done

  # Check for hardcoded secrets (basic detection)
  if echo "$config" | grep -qE "ghp_[A-Za-z0-9]{35,}|github_pat_[A-Za-z0-9]{22,}"; then
    print_error "Hardcoded GitHub token detected in $file (use .env instead)"
    return 1
  fi

  return 0
}

# Check dependencies
if ! command -v jq &> /dev/null && ! command -v python3 &> /dev/null; then
  print_error "Neither jq nor python3 found. Install one: apt install jq (or python3)"
  exit 1
fi

# Main checks
print_header "MCP Configuration Validation"
echo

# 1. Check if .mcp.json or .mcp.example.json exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  if [[ -f "$EXAMPLE_FILE" ]]; then
    print_warn ".mcp.json not found (is OK if first time). Use: cp $EXAMPLE_FILE $CONFIG_FILE"
    print_warn "Checking $EXAMPLE_FILE instead for syntax..."
    CONFIG_FILE="$EXAMPLE_FILE"
  else
    print_error ".mcp.json or $EXAMPLE_FILE not found"
    exit 1
  fi
else
  print_ok ".mcp.json found"
fi

# 2. Check JSON syntax
if command -v jq &> /dev/null; then
  if ! jq empty < "$CONFIG_FILE" 2>/dev/null; then
    print_error "Invalid JSON in $CONFIG_FILE"
    exit 1
  fi
else
  if ! python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
    print_error "Invalid JSON in $CONFIG_FILE"
    exit 1
  fi
fi
print_ok "JSON syntax valid"

# 2b. Check security
if ! validate_security "$CONFIG_FILE"; then
  exit 1
fi

# 3. Extract mcpServers
if command -v jq &> /dev/null; then
  if ! jq -e '.mcpServers' < "$CONFIG_FILE" > /dev/null; then
    print_error "Missing 'mcpServers' key in $CONFIG_FILE"
    exit 1
  fi
else
  if ! python3 -c "import json; d = json.load(open('$CONFIG_FILE')); assert 'mcpServers' in d" 2>/dev/null; then
    print_error "Missing 'mcpServers' key in $CONFIG_FILE"
    exit 1
  fi
fi
print_ok "mcpServers key present"

# 4. Check each server
echo
print_header "Server Validation"
echo

# Extract server names
declare -a servers=()
if command -v jq &> /dev/null; then
  readarray -t servers < <(jq -r '.mcpServers | keys[]' < "$CONFIG_FILE")
else
  readarray -t servers < <(python3 -c "import json; print('\\n'.join(json.load(open('$CONFIG_FILE')).get('mcpServers', {}).keys()))" 2>/dev/null)
fi

for server in "${servers[@]}"; do
  echo -n "  $server: "

  # Extract command, args, and cwd
  if command -v jq &> /dev/null; then
    command=$(jq -r ".mcpServers.\"$server\".command // empty" < "$CONFIG_FILE")
    args=$(jq -r ".mcpServers.\"$server\".args // empty" < "$CONFIG_FILE")
    cwd=$(jq -r ".mcpServers.\"$server\".cwd // empty" < "$CONFIG_FILE")
  else
    command=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('mcpServers', {}).get('$server', {}).get('command', ''))" 2>/dev/null)
    args=$(python3 -c "import json; print('|'.join(json.load(open('$CONFIG_FILE')).get('mcpServers', {}).get('$server', {}).get('args', [])))" 2>/dev/null)
    cwd=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('mcpServers', {}).get('$server', {}).get('cwd', ''))" 2>/dev/null)
  fi

  if [[ -z "$command" ]] || [[ -z "$args" ]]; then
    print_error "command or args missing for $server"
    continue
  fi

  # Check if command exists (for executables like uvx, npx, uv, python)
  if ! command -v "$command" &> /dev/null; then
    # Special handling: some commands may not be in PATH
    if [[ "$command" == "python" ]] || [[ "$command" == "python3" ]]; then
      if command -v python3 &> /dev/null; then
        print_ok "✓ ($command -> python3 available)"
        continue
      fi
    fi
    print_warn "⚠ ($command not in PATH; may be OK if installed differently)"
  else
    print_ok "✓"
  fi

  # If cwd is specified, check it exists
  if [[ -n "$cwd" ]]; then
    # Reject Windows paths on Unix systems
    if [[ "$cwd" == C:/* ]] || [[ "$cwd" =~ ^[A-Z]:\\.*$ ]]; then
      print_error "  → Windows path detected: $cwd (must be absolute Unix path)"
    elif [[ ! -d "$cwd" ]]; then
      print_error "  → cwd directory not found: $cwd"
    else
      verbose "  → cwd exists: $cwd"
    fi
  fi
done

# 5. Call rag mcp-check if available
echo
print_header "Brain-Specific Validation"
echo

if command -v rag &> /dev/null; then
  if rag mcp-check 2>&1; then
    print_ok "rag mcp-check passed"
  else
    print_error "rag mcp-check failed (see above for details)"
  fi
else
  print_warn "⚠ rag command not found. Install: cd packages/kryonix-brain-lightrag && uv sync"
fi

# 6. Summary
echo
print_header "Summary"
echo

if [[ $EXIT_CODE -eq 0 ]]; then
  print_ok "All checks passed!"
  echo "Next: Run 'kryonix mcp check' or 'kryonix mcp doctor' for detailed diagnostics"
else
  print_error "One or more checks failed. See above for details."
  echo "Tips:"
  echo "  1. Ensure paths in .mcp.json are absolute (not relative or ~)"
  echo "  2. Install missing commands (uvx, npx, rag, python)"
  echo "  3. Run 'rag mcp-check' for Brain-specific validation"
fi

exit $EXIT_CODE
