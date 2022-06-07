#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

#TODO remove empty dir

get_ids_to_mount | while read -r PLATFORM; do
  rclone_mount "$ROMSDIR/$PLATFORM"
done
