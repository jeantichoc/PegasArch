#!/bin/bash
pegasarch="$(readlink -f "$0")"
pegasarch_path="$(dirname "$pegasarch")"
source "$pegasarch_path/src/pegasarch.bash"

menu="$1"

if [[ $menu == launch ]] ; then
  shift
  pegasarch_launch "$@"
  exit $?
fi


if [[ $menu == scrap ]] ; then
  shift
  pegasarch_scrap "$@"
  exit $?
fi


if [[ $menu == refresh ]] ; then
  shift
  install_libretro_cores || exit 1
  pegasarch_cloud "$@"
  pegasarch_scrap "$@"
  exit $?
fi


if [[ $menu == pegasus ]] ; then
  shift
  flatpak run org.pegasus_frontend.Pegasus "$@" &
  exit $?
fi


if [[ $menu == cloud ]] ; then
  pegasarch_cloud "$@"
  exit $?
fi


if [[ $menu == cloudsave ]] ; then
  sync_save
  exit $?
fi


if [[ $menu == install-cores ]] ; then
  install_libretro_cores
  exit $?
fi

if [[ $menu == help ]] ; then
  cat $help.txt "$pegasarch_path/resources/help.txt"
  exit 0
fi


if [[ $menu == config ]] ; then
  rclone_config_if_none
  edit_table
  exit 0
fi


if [[ $menu ]] ; then
  echo.red unknown option $menu
  cat $help.txt "$pegasarch_path/resources/help.txt"
  exit 1
fi


check_table || exit 42

if [[ -z $(ls -l "$pegasarch_path/metadatas/*/metadata.pegasus.txt" 2>/dev/null) ]] ; then
  install_libretro_cores || exit 1
  pegasarch_cloud "$@"   || exit 2
  pegasarch_scrap "$@"   || exit 3
fi

sync_save &
flatpak run org.pegasus_frontend.Pegasus &
