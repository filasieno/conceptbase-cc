#!/usr/bin/env bash
# ConceptBase.cc cbserver launcher — Nix port of ProductPOOL/cbserver semantics.
set -euo pipefail

CB_HOME="${CB_HOME:-$(dirname "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")")}"
CB_EXE="${CB_EXE:-$CB_HOME/lib/CBserver}"
export CB_HOME
export CB_POOL="${CB_POOL:-$CB_HOME/share}"
export CBS_DIR="${CBS_DIR:-$CB_HOME/share/serverSources/Prolog_Files}"
export CBL_DIR="${CBL_DIR:-$CB_HOME/share/system-data}"
export CB_VARIANT="${CB_VARIANT:-}"
export PROLOG_VARIANT="${PROLOG_VARIANT:-SWI}"
export SHELL="${SHELL:-/bin/sh}"
export CB_PORTNR="${CB_PORTNR:-4001}"

# Precompiled kernel saved state (qsave_program output shipped beside CBserver).
# When present, load it via `swipl -x` so the kernel is restored from compiled
# bytecode instead of recompiling ~115 .swi.pl sources on every boot. Set
# CB_STATE=_nofile_ (or remove the file) to force loading from source.
CB_STATE="${CB_STATE:-$CB_HOME/lib/cbserver.prc}"
swi_state_args=()
if [[ -f "$CB_STATE" ]]; then
  swi_state_args=(-x "$CB_STATE")
  export CB_KERNEL_STATE="$CB_STATE"
fi

if [[ $# -eq 0 ]]; then
  set -- -u nonpersistent
fi
# SWI expects server flags after "--"; the saved-state flag goes before it.
set -- ${swi_state_args[@]+"${swi_state_args[@]}"} -- "$@"

restart=0
for arg in "$@"; do
  [[ "$arg" = "-r" ]] && restart=1
done

lock="_nofile_"
args=("$@")
for ((i = 0; i < ${#args[@]}; i++)); do
  case "${args[i]}" in
    -d|-db)
      if [[ $((i + 1)) -lt ${#args[@]} ]]; then
        lock="${args[$((i + 1))]}/OB.lock"
      fi
      ;;
  esac
done

if [[ -f "$lock" ]]; then
  pid="$(sed -e 's/.*, PID //' "$lock" 2>/dev/null || true)"
  host="$(sed -e 's/,.*//' "$lock" 2>/dev/null || true)"
  curhost="$(hostname 2>/dev/null || echo localhost)"
  if [[ -n "$pid" && "$host" = "$curhost" ]] && ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$lock"
  fi
fi

if [[ "${1:-}" = "-h" ]]; then
  echo "See ConceptBase User Manual for command line parameters or type CBserver -help"
  exit 0
fi

if [[ "$restart" = "0" ]]; then
  nice "$CB_EXE" "$@"
  crashed=$?
else
  echo a | nice "$CB_EXE" "$@"
  crashed=$?
fi

if [[ "$crashed" = "0" ]]; then
  exit 0
fi

[[ -f "$lock" ]] && rm -f "$lock"

for ((i = 0; i < ${#args[@]}; i++)); do
  if [[ "${args[i]}" = "-r" ]]; then
    sectowait=0
    if [[ $((i + 1)) -lt ${#args[@]} && "${args[$((i + 1))]}" =~ ^[0-9]+$ ]]; then
      sectowait="${args[$((i + 1))]}"
    fi
    sleep "$sectowait"
    exec "$0" "$@"
  fi
done

exit "$crashed"
