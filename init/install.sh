pegasarch="$(readlink -f "$0")"
pegasarch_path="$(dirname "$pegasarch")"

handle_error () {
  local EXITCODE=$?
  echo "--- Failed to $*, exiting with code $EXITCODE ---"
  exit $EXITCODE
}

function echo.blue(){
  echo -e "\033[1;34m$*\033[0m"
}

echo.blue "apt-get update"
sudo apt-get update || handle_error "apt-get update"

#Disable VNC require-encryption
#gsettings set org.gnome.Vino require-encryption false

#Configure bluetooth
#sudo cp -p 91-bluetooth-hci-rules /etc/udev/rules.d/81-bluetooth-hci.rules


echo.blue "installing dependencies ..."
sudo apt-get -qq --assume-yes install make             || handle_error "install make"
sudo apt-get -qq --assume-yes install g++              || handle_error "install g++"
sudo apt-get -qq --assume-yes install qtchooser        || handle_error "install qtchooser"
sudo apt-get -qq --assume-yes install libusb-1.0-0-dev || handle_error "install libusb"
sudo apt-get -qq --assume-yes install cabextract       || handle_error "install cabextract"
sudo apt-get -qq --assume-yes install curl             || handle_error "install curl"
sudo apt-get -qq --assume-yes install git              || handle_error "install git"
sudo apt-get -qq --assume-yes install qt5-default      || handle_error "install qt5-default"
sudo apt-get -qq --assume-yes install rclone           || handle_error "install rclone"
#sudo apt-get -qq --assume-yes install p7zip-full       || handle_error "install p7zip-full"

##### RetroArch
echo.blue "installing retroarch ..."
sudo add-apt-repository ppa:libretro/stable  -y
sudo add-apt-repository ppa:libretro/testing -y
sudo apt-get -qq --assume-yes install retroarch        || handle_error "install retroarch"


##### XOW (Xbox GamePad)
echo.blue "installing xow (driver for xbox like gamepad) ..."
if [[ -z $(systemctl | grep xow.service) ]] ; then
  mkdir -p $HOME/GitHub
  cd $HOME/GitHub
  git clone https://github.com/medusalix/xow
  cd xow
  make BUILD=RELEASE
  sudo make install
  sudo systemctl enable xow
  sudo systemctl start xow
fi



##### Pegasus (front-end)
echo.blue "installing pegasus ..."
sudo apt-get --assume-yes install flatpak
#sudo apt install gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install --assumeyes flathub org.pegasus_frontend.Pegasus


#### Skyscraper (metadata provider)
echo.blue "installing skyscraper ..."
mkdir -p $HOME/GitHub/skyscraper
cd $HOME/GitHub/skyscraper
wget -q -O - https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash
