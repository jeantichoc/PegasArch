#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

bash $SCRIPTPATH/sync.sh
bash $SCRIPTPATH/mount.sh
bash $SCRIPTPATH/scrap.sh
