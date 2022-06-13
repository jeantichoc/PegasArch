#!/bin/bash
script="$(readlink -f "$0")"
script_path="$(dirname "$script")"

menu="$1"


if [[ $menu == scrap ]] ; then
  shift
  bash $script_path/scripts/scrap.sh "$@"
  exit $?
fi


if [[ $menu == refresh ]] ; then
  shift
  bash $script_path/scripts/sync.sh
  bash $script_path/scripts/mount.sh
  bash $script_path/scripts/scrap.sh
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

  bash $script_path/scripts/launch.sh "$@"
  exit $?
fi
