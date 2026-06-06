#!/bin/sh
set -eu

: "${CB_HOME:=/opt/conceptbase}"
: "${CB_PORT:=4001}"
: "${CB_DB:=/var/lib/conceptbase/data}"
: "${CB_DB_NAME:=MYDB}"

export CB_HOME
export PATH="$CB_HOME:$CB_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CB_HOME/linux64/lib:${LD_LIBRARY_PATH:-}"

mkdir -p "$CB_DB"
cd "$CB_DB"

echo "ConceptBase.cc server on port ${CB_PORT}, database ${CB_DB_NAME}"
exec "$CB_HOME/cbserver" -port "$CB_PORT" -d "$CB_DB_NAME" "$@"
