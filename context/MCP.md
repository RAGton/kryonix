# MCP Quick Reference

**MCP** = Model Context Protocol. Enables AI agents (Claude, Cursor) to access Kryonix context safely.

## Structure

```
.mcp.json (user secrets, .gitignore'd)
├── kryonix-brain     → local LightRAG (RAG search, graph, Obsidian)
├── mcp-nixos         → external (packages, options, flakes)
├── vault-readonly    → external (Obsidian vault, read-only)
└── github            → external (issues, PRs, commits, code)
```

## Setup (60 seconds)

1. Copy template: `cp .mcp.example.json .mcp.json`
2. Update paths: Replace `/ABSOLUTE/PATH` placeholders with real paths
3. Add secrets: `export GITHUB_TOKEN=ghp_...` (in `.env`, not `.mcp.json`)
4. Validate: `./scripts/check-mcp.sh` (should show 4 ✓)
5. Register: In Claude/Cursor settings, point to `.mcp.json`

## Validation

| Command | Purpose |
|---------|---------|
| `rag mcp-check` | Brain config + detect secrets |
| `./scripts/check-mcp.sh` | All servers syntax + files exist |
| `kryonix mcp check` | System-level validation |
| `kryonix mcp doctor` | Detailed diagnostics + STDIO test |
| `pytest -q packages/kryonix-brain-lightrag/tests/test_mcp_*.py` | Contract tests |

**All must pass before deployment.**

## Safety Rules

| Rule | Why | Check |
|------|-----|-------|
| No secrets in `.mcp.json` | Prevent git leaks | `rag mcp-check` detects regex |
| All paths absolute | Prevent relative path escape | `rag mcp-check` validates |
| Filesystem server read-only | Prevent accidental writes | Manual review + docs |
| STDIO is pure JSON | Prevent protocol corruption | `test_mcp_stdio_clean.py` |
| `.mcp.json` in `.gitignore` | Protect user config | Verified at commit time |

## Tools per Server

**kryonix-brain:**
- `rag_search` — hybrid graph+vector search with synthesis
- `rag_stats` — knowledge graph stats
- `obsidian_search`, `obsidian_read` — vault navigation

**mcp-nixos:**
- `search_packages`, `get_package_info`
- `search_options`, `get_option_info`

**vault-readonly:**
- `read_file`, `list_directory` (read-only)
- `search_files`

**github:**
- `list_issues`, `get_issue`
- `list_pull_requests`, `get_pull_request`
- `search_code`, `get_file_content`

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Server not found" | Run `./scripts/check-mcp.sh` to find which server failed |
| Secrets leaked | Run `rag mcp-check`; rotate tokens at provider |
| Path errors | Paths must be absolute; see `.mcp.example.json` for format |
| STDIO corruption | Run `kryonix mcp doctor`; check logs in stderr |
| Slow queries | Normal first run (caches built); check internet for external servers |

## Files

- **`.mcp.json`** — User config (secrets + paths), in `.gitignore`
- **`.mcp.example.json`** — Template for new users, version controlled
- **`docs/mcp/README.md`** — Architecture + setup guide
- **`docs/mcp/security.md`** — Threat model + validation gates
- **`docs/mcp/client-configs.md`** — Per-server detailed setup
- **`scripts/check-mcp.sh`** — Bash validation script
- **`packages/kryonix-brain-lightrag/tests/test_mcp_*.py`** — Contract tests

## CLI Commands

```bash
# Validate + fix
rag mcp-check                 # Check Brain config + secrets
./scripts/check-mcp.sh        # All servers validation
kryonix mcp check             # System validation
kryonix mcp doctor            # Diagnostics
kryonix mcp print-config      # Show config (secrets masked)

# Test
pytest -q packages/kryonix-brain-lightrag/tests/test_mcp_*.py

# Use from agent
# (Claude/Cursor: add .mcp.json to settings → restart agent)
```

## Links

- **Setup:** `docs/mcp/README.md`
- **Security:** `docs/mcp/security.md`
- **Per-server guides:** `docs/mcp/client-configs.md`
- **Source code:** `packages/kryonix-brain-lightrag/kryonix_brain_lightrag/server.py`
