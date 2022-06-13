#!/bin/bash

SCRIPT="$(readlink -f "$0")"
script_path="$(dirname "$SCRIPT")"
cd "$script_path/../scripts"

bash ../scripts/sync.sh
bash ../scripts/mount.sh
