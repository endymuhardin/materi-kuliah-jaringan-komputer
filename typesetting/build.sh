#!/usr/bin/env bash
# Build all typst sources to PDFs in output/
# Requires: typst 0.14+, Noto Sans and JetBrains Mono fonts
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

mkdir -p output

shopt -s nullglob
sources=(source/${PREFIX}*.typ)
if (( ${#sources[@]} == 0 )); then
    echo "No source files match prefix '${PREFIX}'"
    exit 1
fi

ok=0
fail=0
for src in "${sources[@]}"; do
    name="$(basename "${src}" .typ)"
    out="output/${name}.pdf"
    echo "Compiling ${src} -> ${out}"
    if typst compile --root . "${src}" "${out}"; then
        ok=$((ok+1))
    else
        fail=$((fail+1))
    fi
done

echo ""
echo "=== Done: $ok succeeded, $fail failed ==="
exit $fail
