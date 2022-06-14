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
  echo.blue "--- Failed to $action $app $new, exiting with code $exit_code ---"
  exit $exit_code
}

# parameter to force a specific version
if [[ $1 ]] ; then
  new="$1"
else
  new=$(wget -q -O - "https://api.github.com/repos/$org/$app/releases/new" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

# go and/or create folder
if [[ -f PegasArch.sh ]] ; then
  pegasarch_path=.
elif [[ -f ../PegasArch.sh ]] ; then
  pegasarch_path=..
else
  read -p "Path for installation: " -i "$HOME/GitHub/PegasArch" -e pegasarch_path
fi
mkdir -p "$pegasarch_path" || exit 1
cd "$pegasarch_path" || exit 2


if [[ ! -f version ]] ; then
  echo "version=0.0.0" > version
fi
source version


if [[ -z $1 && $new == $version ]] ; then
  echo.blue "--- $app is already the version $version, exiting ---"
  echo.blue "You can force a reinstall by removing the version file by running rm version. Then rerun update.sh afterwards."
  exit 0
fi


echo.blue "--- Fetching $app $new ---"
if [[ $1 ]] ; then
  new=$1
  url="https://github.com/$org/$app/archive/refs/heads/$new.tar.gz"
else
  url="https://github.com/$org/$app/archive/$new.tar.gz"
fi
wget -N "$url" || handle_error "fetch"


echo.blue "--- Unpacking ---"

cp -p config.txt .config.txt 2>/dev/null
cp -p resources/artwork.xml resources/.artwork.xml 2>/dev/null
cp -p resources/retroarch.conf resources/.retroarch.conf 2>/dev/null

tar xvzf $new.tar.gz --strip-components 1 --overwrite || handle_error "unpack"
rm $new.tar.gz

mv .config.txt config.txt 2>/dev/null
mv resources/.artwork.xml resources/artwork.xml 2>/dev/null
mv resources/.retroarch.conf resources/retroarch.conf 2>/dev/null


echo.blue "--- Cleaning out old build if one exists ---"

echo.blue "--- Installing $app $new ---"

echo.blue "--- Installing dependencies ---"
bash init/install_dependencies.sh || handle_error "install"

echo.blue "--- $app has been updated to $new ---"
echo "version=$new" > version

exit 0
