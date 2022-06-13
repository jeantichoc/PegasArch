#!/bin/bash
script="$(readlink -f "$0")"
script_path="$(dirname "$script")"/scripts
source $script_path/../init.sh


menu="$1"


if [[ $menu == scrap ]] ; then
  shift
  bash $script_path/scrap.sh "$@"
  exit $?
fi


if [[ $menu == refresh ]] ; then
  shift
  pegasarch_cloud
  bash $script_path/scrap.sh
  exit $?
fi


if [[ $menu == pegasus ]] ; then
  shift
  flatpak run org.pegasus_frontend.Pegasus &
  exit $?
fi


if [[ $menu == cloud ]] ; then
  pegasarch_cloud
  exit $?
fi


if [[ $menu == launch ]] ; then
  shift
  #TODO remove empty dir

  bash $script_path/launch.sh "$@"
  exit $?
fi
