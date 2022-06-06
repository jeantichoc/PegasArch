#!/bin/bash

if [[ -z $(grep set-card-profile /etc/pulse/default.pa) ]] ; then
  sudo echo "set-card-profile alsa_card.pci-0000_00_1b.0 output:hdmi-stereo-extra2+input:analog-stereo" >> /etc/pulse/default.pa
fi

