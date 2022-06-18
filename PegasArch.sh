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
  pegasarch_cloud "$@"
  pegasarch_scrap "$@"
  exit $?
fi


if [[ $menu == pegasus ]] ; then
  shift
  flatpak run org.pegasus_frontend.Pegasus &
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


if [[ $menu == install-dependencies ]] ; then
  shift
  "$pegasarch_path/install-dependencies.sh" "$@"
  install_libretro_cores
  exit $?
fi

if [[ $menu == install-cores ]] ; then
  shift
  install_libretro_cores
  exit $?
fi

if [[ $menu == update ]] ; then
  shift
  "$pegasarch_path/update-PegasArch.sh" "$@"
  exit $?
fi

if [[ $menu ]] ; then
  echo.red unknown option $menu
  exit 1
fi


if [[ $(dir_empty_or_absent "$pegasarch_path/metadatas") == true ]] ; then
  pegasarch_cloud "$@"
  pegasarch_scrap "$@"
fi

sync_save &
flatpak run org.pegasus_frontend.Pegasus &
