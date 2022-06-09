#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

LOG="$SCRIPTPATH/../launcher.log"
CONF="$SCRIPTPATH/../resources/retroarch.conf"

file="$1"
core="$2"

echo $* > $LOG

function setSavConf(){
  echo  "savefile_directory = \"$SAVDIRCLOUD\"" > $CONF
  echo "savestate_directory = \"$SAVDIRCLOUD\"" >> $CONF
}

echo "$retroarch_cmd -f -L \"$core\" \"$1\" --appendconfig $CONF"
$retroarch_cmd -f -L "$core" "$1" >> $LOG 2>&1

#rclone_bisync "$SAVDIR" & >> $LOG 2>&1
