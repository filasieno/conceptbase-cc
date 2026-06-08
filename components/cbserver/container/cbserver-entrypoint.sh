#!/usr/bin/env bash
# Map container environment variables to cbserver CLI flags.
#
# Disk state written by cbserver (OB.*, *.sml, views, TMPDIR copies) is
# documented in components/cbserver/container/Containerfile — see the
# "DISK STATE" and "CONFIGURATION" sections there.
#
# Defaults favour ephemeral sessions: updates are discarded when the process exits.
set -euo pipefail

CB_HOME="${CB_HOME:-/opt/conceptbase}"
export CB_HOME
export CB_POOL="${CB_POOL:-$CB_HOME/share}"
export CBS_DIR="${CBS_DIR:-$CB_HOME/share/serverSources/Prolog_Files}"
export CBL_DIR="${CBL_DIR:-$CB_HOME/share/system-data}"
export CB_PORTNR="${CB_PORTNR:-4001}"
export CB_VARIANT="${CB_VARIANT:-}"
export PROLOG_VARIANT="${PROLOG_VARIANT:-SWI}"
export TMPDIR="${TMPDIR:-/tmp/cbserver}"
mkdir -p "$TMPDIR"

args=()

# --- Database location and persistency ---------------------------------------
# CB_DATABASE: persistent database directory (-d). Files: OB.telos, OB.symbol,
# OB.rule, OB.ruleinfo, OB.ecarule, OB.lock.
# CB_DB_DIR is an alias for CB_DATABASE.
db_dir="${CB_DATABASE:-${CB_DB_DIR:-}}"
db_all="${CB_DB_ALL:-}"
db_new="${CB_NEW_DATABASE:-}"

if [[ -n "$db_new" ]]; then
  args+=(-new "$db_new")
elif [[ -n "$db_all" ]]; then
  args+=(-db "$db_all")
elif [[ -n "$db_dir" ]]; then
  if [[ "${CB_RESET_ON_START:-0}" = "1" ]]; then
    args+=(-new "$db_dir")
  else
    args+=(-d "$db_dir")
  fi
fi

# CB_UPDATE_MODE: persistent | nonpersistent (default nonpersistent)
update_mode="${CB_UPDATE_MODE:-nonpersistent}"
args+=(-u "$update_mode")

# --- Module sources and materialized views -----------------------------------
# CB_LOAD_DIR / CB_SAVE_DIR / CB_VIEWS_DIR map to -load / -save / -views.
[[ -n "${CB_LOAD_DIR:-}" ]] && args+=(-load "$CB_LOAD_DIR")
[[ -n "${CB_SAVE_DIR:-}" ]] && args+=(-save "$CB_SAVE_DIR")
[[ -n "${CB_VIEWS_DIR:-}" ]] && args+=(-views "$CB_VIEWS_DIR")

# --- Network -----------------------------------------------------------------
[[ -n "${CB_PORT:-}" ]] && args+=(-p "$CB_PORT")
[[ -n "${CB_PORTNR:-}" && -z "${CB_PORT:-}" ]] && args+=(-p "$CB_PORTNR")

# --- Tracing and diagnostics -------------------------------------------------
[[ -n "${CB_TRACEMODE:-}" ]] && args+=(-t "$CB_TRACEMODE")

# --- Update / untell behaviour -----------------------------------------------
[[ -n "${CB_UNTELL_MODE:-}" ]] && args+=(-U "$CB_UNTELL_MODE")

# --- Query cache -------------------------------------------------------------
[[ -n "${CB_CACHE_MODE:-}" ]] && args+=(-c "$CB_CACHE_MODE")
[[ -n "${CB_CACHE_SIZE:-}" ]] && args+=(-cs "$CB_CACHE_SIZE")

# --- Optimizer ---------------------------------------------------------------
[[ -n "${CB_OPT_MODE:-}" ]] && args+=(-o "$CB_OPT_MODE")

# --- View maintenance --------------------------------------------------------
[[ -n "${CB_VIEWS_MAINT:-}" ]] && args+=(-v "$CB_VIEWS_MAINT")

# --- Auto-restart after crash ------------------------------------------------
if [[ -n "${CB_RESTART_SECS:-}" ]]; then
  args+=(-r "$CB_RESTART_SECS")
fi

# --- Security and access control ---------------------------------------------
[[ -n "${CB_SECURITY_LEVEL:-}" ]] && args+=(-s "$CB_SECURITY_LEVEL")
[[ -n "${CB_MAX_ERRORS:-}" ]] && args+=(-e "$CB_MAX_ERRORS")
[[ -n "${CB_ADMIN_USER:-}" ]] && args+=(-a "$CB_ADMIN_USER")
[[ -n "${CB_MULTIUSER:-}" ]] && args+=(-mu "$CB_MULTIUSER")

# --- Module listing ----------------------------------------------------------
[[ -n "${CB_MODULE_SEP:-}" ]] && args+=(-ms "$CB_MODULE_SEP")
[[ -n "${CB_MODULE_GEN:-}" ]] && args+=(-mg "$CB_MODULE_GEN")

# --- Predicate typing --------------------------------------------------------
[[ -n "${CB_CC_MODE:-}" ]] && args+=(-cc "$CB_CC_MODE")

# --- Meta-formula compilation ------------------------------------------------
[[ -n "${CB_MAX_COST:-}" ]] && args+=(-mc "$CB_MAX_COST")
[[ -n "${CB_PATH_LEN:-}" ]] && args+=(-pl "$CB_PATH_LEN")
[[ -n "${CB_ITER_MAX:-}" ]] && args+=(-im "$CB_ITER_MAX")

# --- ECA rules ---------------------------------------------------------------
[[ -n "${CB_ECA_MODE:-}" ]] && args+=(-eca "$CB_ECA_MODE")
[[ -n "${CB_ECA_OPT:-}" ]] && args+=(-eo "$CB_ECA_OPT")

# --- Generated formula labels ------------------------------------------------
[[ -n "${CB_RULE_LABELS:-}" ]] && args+=(-rl "$CB_RULE_LABELS")

# --- Client inactivity / server mode -----------------------------------------
[[ -n "${CB_INACTIVITY_HOURS:-}" ]] && args+=(-ia "$CB_INACTIVITY_HOURS")
[[ -n "${CB_SERVER_MODE:-master}" ]] && args+=(-sm "${CB_SERVER_MODE:-master}")

# --- Rule stratification test ------------------------------------------------
[[ -n "${CB_STRAT_MODE:-}" ]] && args+=(-st "$CB_STRAT_MODE")

# --- Special startup commands ------------------------------------------------
[[ -n "${CB_DEV_CMD:-}" ]] && args+=(-g "$CB_DEV_CMD")

# --- Passthrough extra flags (space-separated, quoted values supported) ------
if [[ -n "${CB_EXTRA_ARGS:-}" ]]; then
  # shellcheck disable=SC2206
  extra=($CB_EXTRA_ARGS)
  args+=("${extra[@]}")
fi

if [[ $# -gt 0 ]]; then
  exec cbserver "$@" "${args[@]}"
fi

exec cbserver "${args[@]}"
