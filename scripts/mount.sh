#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

getGamesToMount | while read -r PLATFORM; do
  rcloneMount "$ROMSDIR/$PLATFORM"
done
