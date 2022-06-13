#!/bin/bash

script="$(readlink -f "$0")"
script_path="$(dirname "$script")"
cd "$script_path/../scripts"

bash ../scripts/sync.sh
bash ../scripts/mount.sh
