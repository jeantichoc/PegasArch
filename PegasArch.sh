#!/bin/bash
SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

menu="$1"


if [[ $menu == scrap ]] ; then
  shift
  bash $SCRIPTPATH/scripts/scrap.sh "$@"
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
  shift
  flatpak run org.pegasus_frontend.Pegasus &
  exit $?
fi


if [[ $menu == sync ]] ; then
  shift
  get_ids_to_sync | while read -r PLATFORM; do
    rcloneSync "$ROMSDIR/$PLATFORM"
  done

  rclone_bisync "$SAVDIR"
  exit $?
fi


if [[ $menu == mount ]] ; then
  shift
  #TODO remove empty dir
  get_ids_to_mount | while read -r PLATFORM; do
    rclone_mount "$ROMSDIR/$PLATFORM"
  done
  exit $?
fi



if [[ $menu == launch ]] ; then
  shift
  #TODO remove empty dir

  bash $SCRIPTPATH/scripts/launch.sh "$@"
  exit $?
fi
