#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
. "$SCRIPTPATH/../init/init.sh"

LOG="$SCRIPTPATH/../launcher.log"
CONF="$SCRIPTPATH/../resources/retroarch.conf"

function findCore(){
  local DIRNAME="$(dirname "$1")"
  if [[ $DIRNAME == "/" || $DIRNAME == ""  ]] ; then
    echo ""
    return
  fi
  echo DIR "$DIRNAME" >> $LOG
  local BASENAME="$(basename "$DIRNAME")"
  echo CONSOLE "$BASENAME" >> $LOG
  local core="$(getCore "$BASENAME")"
  if [[ $core ]] ; then
    echo "$core"
  else
    findCore "$DIRNAME"
  fi
}

function setSavConf(){
  echo  "savefile_directory = \"$SAVDIRCLOUD\"" > $CONF
  echo "savestate_directory = \"$SAVDIRCLOUD\"" >> $CONF
}

echo $* > $LOG

CORE=$(findCore "$1")
if [[ -z $CORE ]] ; then
  echo "[ERROR] No core found for $1"
  exit 1
fi

echo retroarch -f -L $CORE "$1" --appendconfig $CONF
retroarch -f -L $CORE "$1" --appendconfig $CONF >> $LOG 2>&1

rcloneBiSync "$SAVDIR" & >> $LOG 2>&1
