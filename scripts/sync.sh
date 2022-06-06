#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

getGamesToSync | while read -r PLATFORM; do
  rcloneSync "$ROMSDIR/$PLATFORM"
done

rcloneBiSync "$SAVDIR"
