# MCP (Model Context Protocol) Integration

Kryonix integrates multiple **Model Context Protocol** servers to enable AI agents (Claude, Cursor, VS Code) to safely access project context, configuration, and knowledge.

## Architecture

MCP provides a **two-tier client-server architecture** for agent interaction:

```
┌─────────────────────┐
│  AI Agent           │
│  (Claude/Cursor)    │
└──────────┬──────────┘
           │ JSON-RPC 2.0 over STDIO
           │
    ┌──────┴──────────────────────────┐
    │                                  │
┌───▼─────────────┐        ┌──────────▼────────┐
│ Brain MCP       │        │ External MCPs     │
│ (LightRAG RAG)  │        │                   │
├─────────────────┤        ├───────────────────┤
│ Local Stdio     │        │ mcp-nixos         │
│ JSON-RPC 2.0    │        │ filesystem        │
│ tools:          │        │ (read-only vault) │
│ • rag_search    │        │ GitHub            │
│ • rag_ask       │        │                   │
│ • graph_heal    │        │ Each stdin/stdout │
│ • obsidian_*    │        │ or HTTP           │
└─────────────────┘        └───────────────────┘
```

### Servers

| Server | Type | Location | Purpose |
|--------|------|----------|---------|
| **kryonix-brain** | Local | `packages/kryonix-brain-lightrag/` | LightRAG knowledge graph, Obsidian vault search |
| **mcp-nixos** | External | `uvx mcp-nixos` | NixOS packages, options, Home Manager, flakes |
| **filesystem** | External | `@modelcontextprotocol/server-filesystem` | Read-only Obsidian vault access |
| **github** | External | `@modelcontextprotocol/server-github` | GitHub issues, PRs, commits, file content |

## Configuration

MCP servers are registered in **`.mcp.json`** (user-scoped, not version controlled):

```json
{
  "mcpServers": {
    "mcp-nixos": {
      "command": "uvx",
      "args": ["mcp-nixos"]
    },
    "vault-readonly": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/absolute/path/to/vault"]
    },
    "kryonix-brain": {
      "command": "uv",
      "args": ["run", "--project", "packages/kryonix-brain-lightrag", "python", "-m", "kryonix_brain_lightrag.server"],
      "cwd": "/absolute/path/to/kryonix"
    }
  }
}
```

**Key rules:**
- `.mcp.json` is **in `.gitignore`** — user secrets never committed
- Use `.mcp.example.json` as a template
- All paths must be **absolute** (not relative or `~`)
- Secrets (API keys, tokens) go in **environment variables**, not the JSON file
- Each server has `command` + `args` + optional `cwd` and `env`

## Quick Start: Claude / Cursor

### Step 1: Create `.mcp.json`

```bash
cp .mcp.example.json .mcp.json
# Edit .mcp.json: replace /ABSOLUTE/PATH placeholders with real paths
# Add GITHUB_TOKEN env var if using GitHub server
```

### Step 2: Validate Configuration

```bash
rag mcp-check              # Check Brain server config + detect secrets
./scripts/check-mcp.sh     # Full validation (syntax, files, externals)
kryonix mcp check          # System-level validation
```

### Step 3: Register with Claude / Cursor

In **Claude** or **Cursor**:
1. Open settings → **MCP settings** or **Model context protocol**
2. Point to `.mcp.json` in your Kryonix project directory
3. Click "Trust" to allow MCP server access
4. Restart the agent

The servers should now be available in your agent chat context.

### Step 4: Verify

```bash
kryonix mcp doctor         # Detailed diagnostics
kryonix mcp print-config   # Show masked config
```

You should see all 4 servers listed as ✓ or ⚠ (if not configured).

## Validation Workflow

Before deploying or committing MCP changes:

```bash
# 1. Syntax + file validation
./scripts/check-mcp.sh

# 2. Brain-specific checks (secrets, paths, permissions)
rag mcp-check

# 3. Run MCP tests
pytest -q packages/kryonix-brain-lightrag/tests/test_mcp_*.py

# 4. Full system check
kryonix mcp check
kryonix mcp doctor
```

All must show ✓ before a change is ready.

## Common Issues

### "Server not found" or "Command not available"

- **mcp-nixos:** Install via `uvx mcp-nixos --help` (requires Python + pip)
- **filesystem/github:** Install via `npm install -g @modelcontextprotocol/server-filesystem`
- **kryonix-brain:** Run `cd packages/kryonix-brain-lightrag && uv sync` to install deps

### Path errors in `.mcp.json`

- All paths must be **absolute** (e.g., `/home/user/kryonix`, not `~/kryonix` or `../`)
- On Windows, use `C:\Users\...` format (escaping backslashes in JSON: `C:\\Users\\...`)
- Use `.mcp.example.json` as template and update placeholders

### Server hangs or timeout

- Check server is responsive: `kryonix mcp doctor --verbose`
- Check logs in stderr (Brain server logs go to `~/.kryonix-brain/logs/`)
- Restart agent and retry

### Secrets appearing in logs

- Check `.mcp.json` for API keys/tokens (should not be there)
- Run `rag mcp-check` — it will detect and warn about exposed secrets
- Use environment variables instead (see **Security** section)

## For More Information

- **Security & threat model:** See `docs/mcp/security.md`
- **Per-server setup:** See `docs/mcp/client-configs.md`
- **Quick reference:** See `context/MCP.md`
- **CLI commands:** Run `kryonix mcp --help` or `rag mcp-check --help`
