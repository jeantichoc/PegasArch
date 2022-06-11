#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

menu="$1"

if [[ $menu == scrap ]] ; then
  shift
  bash $SCRIPTPATH/scripts/scrap.sh $*
  exit $?
fi

if [[ $menu == refresh ]] ; then
  shift
  bash $SCRIPTPATH/scripts/sync.sh
  bash $SCRIPTPATH/scripts/mount.sh
  bash $SCRIPTPATH/scripts/scrap.sh
  exit $?
fi

if [[ $menu == pegasus ]] ; then
  flatpak run org.pegasus_frontend.Pegasus &
  exit $?
fi
