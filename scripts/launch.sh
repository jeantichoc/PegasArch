#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

LOG="$SCRIPTPATH/../launcher.log"
CONF="$SCRIPTPATH/../resources/retroarch.conf"


echo $* > $LOG

function setSavConf(){
  echo  "savefile_directory = \"$SAVDIRCLOUD\"" > $CONF
  echo "savestate_directory = \"$SAVDIRCLOUD\"" >> $CONF
}

function get_or_install_core(){
  core="$(get_core_for_file "$1")"
  if [[ -z $core ]] ; then
    echo "[ERROR] No core found for $1"
    exit 1
  fi

  core_file="$(find_core_file "$core")"
  if [[ ! -f $core_file ]] ; then
    sudo apt-get --assume-yes install libretro-$core
    core_file="$(find_core_file "$core")"
  fi

  echo ${core_file:-${core}}
}



core="$(get_or_install_core "$1")"

echo "$retroarch_cmd -f -L \"$core\" \"$1\" --appendconfig $CONF"
$retroarch_cmd -f -L "$core" "$1" >> $LOG 2>&1

#rclone_bisync "$SAVDIR" & >> $LOG 2>&1
