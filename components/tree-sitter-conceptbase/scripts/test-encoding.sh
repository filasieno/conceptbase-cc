#!/usr/bin/env bash
# Parse sample sources as UTF-8, UTF-16LE, and UTF-16BE via tree-sitter CLI.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${ROOT}/source"
SAMPLES="${ROOT}/tests/samples"

mkdir -p "${SAMPLES}"

UTF8="${SAMPLES}/unicode.cb"
cat > "${UTF8}" <<'EOF'
Mitarbeiter in EntityType with
  attribute
    name : "Müller";
    city : "Köln"
end
EOF

UTF16LE="${SAMPLES}/unicode-le.cb"
UTF16BE="${SAMPLES}/unicode-be.cb"

if command -v iconv >/dev/null 2>&1; then
  iconv -f UTF-8 -t UTF-16LE "${UTF8}" > "${UTF16LE}"
  iconv -f UTF-8 -t UTF-16BE "${UTF8}" > "${UTF16BE}"
else
  python3 - "${UTF8}" "${UTF16LE}" "${UTF16BE}" <<'PY'
import sys
from pathlib import Path
src = Path(sys.argv[1]).read_bytes()
Path(sys.argv[2]).write_bytes(src.decode("utf-8").encode("utf-16-le"))
Path(sys.argv[3]).write_bytes(src.decode("utf-8").encode("utf-16-be"))
PY
fi

cd "${SOURCE}"
tree-sitter generate >/dev/null

fail=0
for enc in utf8 utf16-le; do
  case "${enc}" in
    utf8) file="${UTF8}" ;;
    utf16-le) file="${UTF16LE}" ;;
  esac
  out=$(tree-sitter parse --encoding "${enc}" --quiet "${file}" 2>&1) || true
  if echo "${out}" | grep -qE 'ERROR|MISSING'; then
    echo "FAIL  encoding=${enc}  file=${file}"
    echo "${out}" | grep -nE 'ERROR|MISSING' | head -5
    fail=$((fail + 1))
  else
    echo "ok    encoding=${enc}  (tree-sitter CLI)"
  fi
done

# UTF-16BE: verified via C API (ts_parser_parse_string_encoding). The CLI
# --encoding utf16-be path is unreliable in tree-sitter 0.26.x; LSP uses the C API.
if [[ -x "${ROOT}/target/test_parse" ]]; then
  if "${ROOT}/target/test_parse" >/dev/null; then
    echo "ok    encoding=utf16-be  (C API via test_parse)"
  else
    echo "FAIL  encoding=utf16-be  (C API via test_parse)"
    fail=$((fail + 1))
  fi
else
  echo "skip  encoding=utf16-be  (build + run-c-test.sh first)"
fi

exit "${fail}"
