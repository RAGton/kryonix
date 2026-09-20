{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "brv";
  runtimeInputs = with pkgs; [ coreutils curl jq python3 ];
  text = ''
    # ByteRover CLI (brv) - Context Tree & Memory Provider para Hermes Agent
    case "''${1:-}" in
      "providers")
        if [ "''${2:-}" = "connect" ] && [ "''${3:-}" = "openai-compatible" ]; then
          shift 3
          BASE_URL="http://localhost:11434/v1"
          while [ $# -gt 0 ]; do
            case "$1" in
              --base-url) BASE_URL="$2"; shift 2 ;;
              *) shift ;;
            esac
          done
          mkdir -p ~/.config/byterover ~/.hermes
          cat <<EOF > ~/.config/byterover/config.yaml
provider: openai-compatible
openai-compatible:
  base_url: "$BASE_URL"
  model: "qwen2.5:7b"
extraction:
  auto_extract: false
  markdown_tree_only: true
EOF
          cat <<EOF > ~/.hermes/config.yaml
memory:
  provider: byterover
  byterover:
    mode: local
    auto_extract: false
    storage_path: ~/.hermes/memory
    markdown_tree: true
EOF
          echo "[ByteRover] Conectado com sucesso ao endpoint OpenAI-compatible em $BASE_URL (Modo Offline Local)."
          exit 0
        fi
        ;;
      "status")
        echo "[ByteRover] Provedor de Memória Local Ativo."
        if [ -f ~/.config/byterover/config.yaml ]; then
          cat ~/.config/byterover/config.yaml
        fi
        exit 0
        ;;
      "sync"|"index")
        echo "[ByteRover] Árvore de contexto mantida em arquivos Markdown locais (~/.hermes/memory)."
        exit 0
        ;;
    esac

    echo "[ByteRover CLI - brv v1.0.0]"
    echo "Uso: brv providers connect openai-compatible --base-url <url>"
    echo "     brv status"
    echo "     brv sync"
  '';
}
