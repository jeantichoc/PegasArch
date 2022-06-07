#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

get_ids_to_sync | while read -r PLATFORM; do
  rcloneSync "$ROMSDIR/$PLATFORM"
done

rclone_bisync "$SAVDIR"
