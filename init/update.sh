#!/bin/bash
{
  ORG=jeantichoc
  APP=PegasArch
  LATEST=`wget -q -O - "https://api.github.com/repos/$ORG/$APP/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'`

  if [[ ! -f VERSION ]] ; then
    echo "VERSION=0.0.0" > VERSION
  fi
  source VERSION

  handle_error () {
    local EXITCODE=$?
    local ACTION=$1
    rm --force VERSION
    echo "--- Failed to $ACTION $APP v.${LATEST}, exiting with code $EXITCODE ---"
    exit $EXITCODE
  }

  if [[ $LATEST == $VERSION ]] ; then
    echo "--- $APP is already the latest version, exiting ---"
    echo "You can force a reinstall by removing the VERSION file by running rm VERSION. Then rerun ./update_$APP.sh afterwards."
    exit 0
  fi

  echo "--- Fetching $APP v.$LATEST ---"
  wget -N "https://github.com/$ORG/$APP/archive/${LATEST}.tar.gz" || handle_error "fetch"

  echo "--- Unpacking ---"
  cp -p config.txt .config.txt 2>/dev/null
  tar xvzf $LATEST.tar.gz --strip-components 1 --overwrite || handle_error "unpack"
  rm $LATEST.tar.gz

  mv .config.txt config.txt 2>/dev/null


  echo "--- Cleaning out old build if one exists ---"

  echo "--- Installing $APP v.$LATEST ---"
  #bash init/install.sh || handle_error "install"
  echo "--- $APP has been updated to v.$LATEST ---"

  exit 0
}
