#!/usr/bin/env bash
# Build all typst sources to PDFs in output/
# Pre-step: render any Mermaid .mmd diagrams in typesetting/diagram/ to PNG via mmdc.
#
# Requires:
#   - typst 0.14+
#   - mmdc (mermaid-cli) for diagram rendering
#   - Noto Sans + JetBrains Mono fonts (brew install --cask font-noto-sans font-jetbrains-mono)
#
# Usage:
#   typesetting/build.sh          # build all
#   typesetting/build.sh uts      # build only sources matching "uts*"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PREFIX="${1:-}"

cd "${REPO_ROOT}"

if ! command -v typst >/dev/null 2>&1; then
    echo "ERROR: typst not installed. Install with: brew install typst" >&2
    exit 1
fi

# ─── Step 1: Render Mermaid diagrams (mmd -> png) ─────────────────────────
shopt -s nullglob
mmd_files=(typesetting/diagram/*.mmd)
if (( ${#mmd_files[@]} > 0 )); then
    if ! command -v mmdc >/dev/null 2>&1; then
        echo "ERROR: mmdc not installed. Install with: npm install -g @mermaid-js/mermaid-cli" >&2
        exit 1
    fi
    echo "=== Rendering ${#mmd_files[@]} Mermaid diagram(s) ==="
    for f in "${mmd_files[@]}"; do
        out="${f%.mmd}.png"
        echo "  $f -> $out"
        mmdc -i "$f" -o "$out" --quiet \
            --puppeteerConfigFile typesetting/puppeteer-config.json \
            --scale 3 --width 1600 --backgroundColor transparent
    done
fi

# ─── Step 2: Compile Typst sources ────────────────────────────────────────
mkdir -p output
sources=(source/${PREFIX}*.typ)
if (( ${#sources[@]} == 0 )); then
    echo "No source files match prefix '${PREFIX}'"
    exit 1
fi

echo "=== Compiling ${#sources[@]} Typst source(s) ==="
ok=0
fail=0
for src in "${sources[@]}"; do
    name="$(basename "${src}" .typ)"
    out="output/${name}.pdf"
    echo "  ${src} -> ${out}"
    if typst compile --root . "${src}" "${out}"; then
        ok=$((ok+1))
    else
        fail=$((fail+1))
    fi
done

echo ""
echo "=== Done: $ok succeeded, $fail failed ==="
exit $fail
