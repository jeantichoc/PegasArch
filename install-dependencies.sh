#!/bin/bash

pegasarch=PegasArch.sh
pegasarch_path=$HOME/GitHub/PegasArch
if [[ -f $pegasarch ]] ; then
  pegasarch_path=.
elif [[ -f ../$pegasarch ]] ; then
  pegasarch_path=..
fi

pegasarch_path=$(realpath $pegasarch_path)
pegasarch=$pegasarch_path/$pegasarch

handle_error () {
  local EXITCODE=$?
  echo "--- Failed to $*, exiting with code $EXITCODE ---"
  exit $EXITCODE
}

function echo.blue(){
  echo -e "\033[1;34m$*\033[0m"
}

echo.blue "apt-get update"
sudo apt-get -qq update || handle_error "apt-get update"


##### dependencies
echo.blue "installing dependencies ..."
sudo apt-get -qq --assume-yes install make             || handle_error "install make"
sudo apt-get -qq --assume-yes install g++              || handle_error "install g++"
sudo apt-get -qq --assume-yes install qtchooser        || handle_error "install qtchooser"
sudo apt-get -qq --assume-yes install libusb-1.0-0-dev || handle_error "install libusb"
sudo apt-get -qq --assume-yes install cabextract       || handle_error "install cabextract"
sudo apt-get -qq --assume-yes install curl             || handle_error "install curl"
sudo apt-get -qq --assume-yes install git              || handle_error "install git"
sudo apt-get -qq --assume-yes install qt5-default      || handle_error "install qt5-default"
sudo apt-get -qq --assume-yes install libqt5xml5       || handle_error "install libqt5xml5"


##### rclone
echo.blue "installing rclone ..."
curl https://rclone.org/install.sh | sudo bash


##### RetroArch
echo.blue "installing retroarch ..."
sudo add-apt-repository ppa:libretro/stable  -y >/dev/null
sudo add-apt-repository ppa:libretro/testing -y >/dev/null
sudo apt-get -qq --assume-yes install retroarch        || handle_error "install retroarch"
retroarch --version

##### Pegasus (front-end)
echo.blue "installing pegasus ..."
sudo apt-get -qq --assume-yes install flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install --or-update --assumeyes --noninteractive flathub org.pegasus_frontend.Pegasus


#### Skyscraper (metadata provider)
echo.blue "installing skyscraper ..."
mkdir -p "$pegasarch_path/skyscraper" || exit 1
cd "$pegasarch_path/skyscraper" || exit 2
wget -q -O - https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash
scraper_cmd=$(realpath "Skyscraper")
sed "s|scraper_cmd=.*|scraper_cmd='$scraper_cmd'|" -i "$pegasarch_path/config.txt"


#### Add PegasArch alias
if [[ ! $(grep -F "$pegasarch" "$HOME/.bashrc") ]] ; then
  sed -i '/^ *alias *PegasArch=.*/d' "$HOME/.bashrc"
  echo "alias PegasArch=\"'$pegasarch'\"" >> "$HOME/.bashrc"
  alias PegasArch="'$pegasarch'"
fi
