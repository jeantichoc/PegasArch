#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

LOG="$SCRIPTPATH/../launcher.log"
CONF="$SCRIPTPATH/../resources/retroarch.conf"

file="$1"
core="$2"

echo $* > $LOG

function configure_retroarch(){
  sed "s|^savefile_directory *= *PEGASARCH *|savefile_directory = $emulator_saves|"   -i $retroarch_superconf
  sed "s|^savestate_directory *= *PEGASARCH *|savestate_directory = $emulator_states|" -i $retroarch_superconf
}

mkdir -p $emulator_saves
mkdir -p $emulator_states

echo "$retroarch_cmd -f -L \"$core\" \"$1\" --appendconfig $retroarch_superconf"
$retroarch_cmd -f -L "$core" "$1" --appendconfig $retroarch_superconf >> $LOG 2>&1

#rclone_bisync "$SAVDIR" & >> $LOG 2>&1
