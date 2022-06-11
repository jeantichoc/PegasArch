#!/bin/bash

org=jeantichoc
app=PegasArch

function echo.blue (){
  echo -e "\e[1;34m$*\033[0m"
}

function handle_error () {
  local exit_code=$?
  local action=$1
  rm --force version
  echo.blue "--- Failed to $action $app v.${latest}, exiting with code $exit_code ---"
  exit $exit_code
}


if [[ $1 ]] ; then
  latest="$1"
else
  latest=$(wget -q -O - "https://api.github.com/repos/$org/$app/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi


if [[ ! -f version ]] ; then
  echo "version=0.0.0" > version
fi
source version


if [[ $latest == $version ]] ; then
  echo.blue "--- $app is already the latest version, exiting ---"
  echo.blue "You can force a reinstall by removing the version file by running rm version. Then rerun ./update_$app.sh afterwards."
  exit 0
fi

echo.blue "--- Fetching $app v.$latest ---"
if [[ $1 == HEAD ]] ; then
  url="https://github.com/$org/$app/archive/refs/heads/main.tar.gz"
  latest=main
else
  url="https://github.com/$org/$app/archive/${latest}.tar.gz"
fi
wget -N "$url" || handle_error "fetch"

echo.blue "--- Unpacking ---"

cp -p config.txt .config.txt 2>/dev/null
cp -p resources/artwork.xml resources/.artwork.xml 2>/dev/null
cp -p resources/retroarch.conf resources/.retroarch.conf 2>/dev/null

tar xvzf $latest.tar.gz --strip-components 1 --overwrite || handle_error "unpack"
rm $latest.tar.gz

mv .config.txt config.txt 2>/dev/null
mv resources/.artwork.xml resources/artwork.xml 2>/dev/null
mv resources/.retroarch.conf resources/retroarch.conf 2>/dev/null


echo.blue "--- Cleaning out old build if one exists ---"

echo.blue "--- Installing $app v.$latest ---"
#bash init/install.sh || handle_error "install"
echo.blue "--- $app has been updated to v.$latest ---"

exit 0
