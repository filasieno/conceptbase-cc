#!/usr/bin/env bash
# Prune migrated files from archive/2026-06-06-wip and record git moves (not copies)
# into components/. Run from repo root with a staged migration index.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/archive/2026-06-06-wip"
DRY_RUN="${DRY_RUN:-0}"

log() { printf '%s\n' "$*"; }
run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

# --- archive path → components path (relative to repo root) ---
java_dest() {
  local rel="$1" # path under ProductPOOL/java/
  case "$rel" in
    i5/ShallowCloneable.java)
      echo "components/java/cbcommon/src/main/java/i5/ShallowCloneable.java" ;;
    i5/cb/CBConfiguration.java|i5/cb/CBException.java|i5/cb/CBinstaller.java|i5/cb/Contract.java|i5/cb/PrologPreProcessor.java)
      echo "components/java/cbcommon/src/main/java/$rel" ;;
    i5/cb/CBShell.java)
      echo "components/java/cbapi/src/main/java/$rel" ;;
    i5/cb/GUIHandler.java)
      echo "components/java/cbgraph/src/main/java/$rel" ;;
    i5/cb/api/*)
      echo "components/java/cbapi/src/main/java/$rel" ;;
    i5/cb/telos/frame/*)
      echo "components/java/cbframe/src/main/java/$rel" ;;
    i5/cb/telos/*)
      echo "components/java/cbtelos/src/main/java/$rel" ;;
    i5/cb/graph/*)
      if [[ "$rel" == *.gif || "$rel" == *.png ]]; then
        echo "components/java/cbgraph/src/main/resources/$rel"
      else
        echo "components/java/cbgraph/src/main/java/$rel"
      fi
      ;;
    i5/cb/workbench/*)
      if [[ "$rel" == *.gif ]]; then
        echo "components/java/cbworkbench/src/main/resources/$rel"
      else
        echo "components/java/cbworkbench/src/main/java/$rel"
      fi
      ;;
    manifest.txt|CBinstaller-manifest.txt)
      echo "components/java/cbdistribution/$rel" ;;
    resources/*)
      echo "components/java/cbdistribution/src/main/resources/${rel#resources/}" ;;
    *)
      return 1 ;;
  esac
}

c_lib_dest() {
  local arch_lib="$1" base="$2"
  local comp
  case "$arch_lib" in
    libGeneral) comp=libcbgeneral ;;
    libIpc) comp=libcbipc ;;
    libtelos) comp=libcbtelos ;;
    libtelosServer) comp=libcbtelosserver ;;
    libCos3) comp=libcbcos ;;
    libCB) comp=libcbc ;;
    libCBview) comp=libcbcview ;;
    libtelos) comp=libcbtelosclient ;;
    *) return 1 ;;
  esac
  # Prefer src/ for sources; headers may live under include/conceptbase/
  if [[ -f "$ROOT/components/$comp/src/$base" ]]; then
    echo "components/$comp/src/$base"
  elif [[ -f "$ROOT/components/$comp/include/conceptbase/$base" ]]; then
    echo "components/$comp/include/conceptbase/$base"
  else
    return 1
  fi
}

fix_pair() {
  local archive_rel="$1" component_rel="$2"
  local ap="$ROOT/$archive_rel" cp="$ROOT/$component_rel"
  local arch_tracked=0 comp_tracked=0

  [[ -f "$ap" ]] || return 0
  [[ -f "$cp" ]] || return 0

  git ls-files --error-unmatch "$archive_rel" &>/dev/null && arch_tracked=1
  git ls-files --error-unmatch "$component_rel" &>/dev/null && comp_tracked=1

  [[ "$arch_tracked" -eq 1 ]] || return 0

  if [[ "$comp_tracked" -eq 1 ]]; then
    if cmp -s "$ap" "$cp"; then
      log "rm  $archive_rel (duplicate of tracked $component_rel)"
      run git rm -f -- "$archive_rel"
    else
      log "rm  $archive_rel (migrated; $component_rel differs)"
      run git rm -f -- "$archive_rel"
    fi
    return
  fi

  if cmp -s "$ap" "$cp"; then
    log "mv  $archive_rel → $component_rel (identical)"
    run git mv -f "$archive_rel" "$component_rel"
  else
    log "rm  $archive_rel (migrated; component differs)"
    run git rm -f -- "$archive_rel"
  fi
}

log "==> prune examples duplicated in components/examples/src"
while IFS= read -r -d '' cf; do
  rel="${cf#"$ROOT/components/examples/src/"}"
  ar="archive/2026-06-06-wip/ProductPOOL/examples/$rel"
  fix_pair "$ar" "components/examples/src/$rel"
done < <(find "$ROOT/components/examples/src" -type f -print0)

log "==> prune server-engine (.swi.pl)"
while IFS= read -r -d '' cf; do
  base="$(basename "$cf")"
  fix_pair "archive/2026-06-06-wip/ProductPOOL/linux/serverSources/Prolog_Files/$base" \
            "components/server-engine/src/$base"
done < <(find "$ROOT/components/server-engine/src" -name '*.swi.pl' -print0)

log "==> prune grammar-compiler"
for base in dcg.pl parseAss.dcg parseAss_dcg.pro sml_gramm.dcg tokens.dcg tokens_dcg.pro; do
  fix_pair "archive/2026-06-06-wip/ProductPOOL/serverSources/Prolog_Files/$base" \
           "components/grammar-compiler/src/$base"
done

log "==> prune system-data"
while IFS= read -r -d '' cf; do
  base="$(basename "$cf")"
  fix_pair "archive/2026-06-06-wip/ProductPOOL/lib/$base" "components/system-data/src/$base"
done < <(find "$ROOT/components/system-data/src" -type f -print0)

log "==> prune Java (archive ProductPOOL/java → components/java)"
while IFS= read -r -d '' jf; do
  rel="${jf#"$ARCH/ProductPOOL/java/"}"
  dest="$(java_dest "$rel")" || continue
  fix_pair "archive/2026-06-06-wip/ProductPOOL/java/$rel" "$dest"
done < <(find "$ARCH/ProductPOOL/java" -type f \( -name '*.java' -o -name 'manifest.txt' -o -name 'CBinstaller-manifest.txt' \) ! -path '*/tests/*' -print0)

# Resources (gif/png) under graph/workbench
while IFS= read -r -d '' rf; do
  rel="${rf#"$ARCH/ProductPOOL/java/"}"
  dest="$(java_dest "$rel")" || continue
  fix_pair "archive/2026-06-06-wip/ProductPOOL/java/$rel" "$dest"
done < <(find "$ARCH/ProductPOOL/java" -type f \( -name '*.gif' -o -name '*.png' \) -print0)

while IFS= read -r -d '' rf; do
  rel="${rf#"$ARCH/ProductPOOL/java/resources/"}"
  fix_pair "archive/2026-06-06-wip/ProductPOOL/java/resources/$rel" \
            "components/java/cbdistribution/src/main/resources/$rel"
done < <(find "$ARCH/ProductPOOL/java/resources" -type f -print0 2>/dev/null || true)

log "==> prune server C libs (linux + serverSources + clientSources)"
for arch_lib in libGeneral libIpc libtelos libtelosServer libCos3; do
  for adir in \
    "$ARCH/ProductPOOL/linux/serverSources/C_Files/$arch_lib" \
    "$ARCH/ProductPOOL/serverSources/C_Files/$arch_lib"; do
    [[ -d "$adir" ]] || continue
    while IFS= read -r -d '' sf; do
      base="$(basename "$sf")"
      dest="$(c_lib_dest "$arch_lib" "$base")" || continue
      arch_prefix="${adir#"$ROOT"/}"
      fix_pair "$arch_prefix/$base" "$dest"
    done < <(find "$adir" -type f \( -name '*.c' -o -name '*.cc' -o -name '*.h' \) -print0)
  done
done

for pair in "libCB:libcbc" "libCBview:libcbcview" "libtelos:libcbtelosclient"; do
  arch_lib="${pair%%:*}"
  comp="${pair##*:}"
  adir="$ARCH/ProductPOOL/clientSources/$arch_lib"
  [[ -d "$adir" ]] || continue
  while IFS= read -r -d '' sf; do
    base="$(basename "$sf")"
    if [[ -f "$ROOT/components/$comp/src/$base" ]]; then
      fix_pair "archive/2026-06-06-wip/ProductPOOL/clientSources/$arch_lib/$base" \
                "components/$comp/src/$base"
    elif [[ -f "$ROOT/components/$comp/tests/$base" ]]; then
      fix_pair "archive/2026-06-06-wip/ProductPOOL/clientSources/$arch_lib/$base" \
                "components/$comp/tests/$base"
    fi
  done < <(find "$adir" -type f \( -name '*.c' -o -name '*.cc' -o -name '*.h' -o -name '*.l' -o -name '*.y' \) -print0)
done

log "==> prune cbserver glue"
for base in swiMain.c install_libs.h; do
  [[ -f "$ROOT/components/cbserver/src/$base" ]] || continue
  for ar in \
    "archive/2026-06-06-wip/ProductPOOL/linux/serverSources/$base" \
    "archive/2026-06-06-wip/ProductPOOL/serverSources/$base"; do
    fix_pair "$ar" "components/cbserver/src/$base"
  done
done

log "==> prune plcb / server-repl"
fix_pair "archive/2026-06-06-wip/ProductPOOL/linux/serverSources/swiInteractive.c" \
         "components/plcb/src/swiInteractive.c"
fix_pair "archive/2026-06-06-wip/ProductPOOL/serverSources/swiInteractive.c" \
         "components/plcb/src/swiInteractive.c"

log "==> remove empty migrated trees from archive (filesystem + index)"
PRUNE_DIRS=(
  "ProductPOOL/examples"
  "ProductPOOL/linux/serverSources/Prolog_Files"
  "ProductPOOL/linux/serverSources/C_Files/libGeneral"
  "ProductPOOL/linux/serverSources/C_Files/libIpc"
  "ProductPOOL/linux/serverSources/C_Files/libtelos"
  "ProductPOOL/linux/serverSources/C_Files/libtelosServer"
  "ProductPOOL/linux/serverSources/C_Files/libCos3"
  "ProductPOOL/serverSources/C_Files/libGeneral"
  "ProductPOOL/serverSources/C_Files/libIpc"
  "ProductPOOL/serverSources/C_Files/libTelos"
  "ProductPOOL/serverSources/C_Files/libtelos"
  "ProductPOOL/serverSources/C_Files/libtelosServer"
  "ProductPOOL/serverSources/C_Files/libCos3"
  "ProductPOOL/clientSources/libCB"
  "ProductPOOL/clientSources/libCBview"
  "ProductPOOL/clientSources/libtelos"
  "ProductPOOL/java/i5"
  "ProductPOOL/java/resources"
  "ProductPOOL/lib"
)

for d in "${PRUNE_DIRS[@]}"; do
  path="$ARCH/$d"
  if [[ -d "$path" ]]; then
    remaining="$(find "$path" -type f 2>/dev/null | wc -l)"
    if [[ "$remaining" -eq 0 ]]; then
      log "rmdir tree $d"
      run git rm -rf --ignore-unmatch "archive/2026-06-06-wip/$d" 2>/dev/null || true
      run rm -rf "$path"
    else
      log "keep  $d ($remaining files not migrated)"
    fi
  fi
done

log "==> summary"
git diff --cached --name-status | awk '{print $1}' | sort | uniq -c | sort -rn | head -15
