#!/usr/bin/env bash
# Regenerate JavaCC parser sources from *.jj grammars (cbframe Telos, cbapi Notification).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JAVA="$ROOT/components/java"

cd "$JAVA"
mvn -pl cbframe,cbapi generate-sources "$@"

echo "Generated sources (src/main/java):"
find cbframe/src/main/java/i5/cb/telos/frame cbapi/src/main/java/i5/cb/api/notification \
  -maxdepth 1 \( -name '*Parser*.java' -o -name 'Token.java' -o -name 'ParseException.java' \
  -o -name 'SimpleCharStream.java' -o -name 'TokenMgrError.java' \) 2>/dev/null | sort
