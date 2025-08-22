#!/bin/bash 
set -o xtrace
if (pw-cli e alsa_card.pci-0000_00_1b.0 Spa:Enum:ParamId:Profile | grep output:iec958-stereo+input:analog-stereo)
then
    pw-cli s alsa_card.pci-0000_00_1b.0 Spa:Enum:ParamId:Profile {name:\"output:analog-stereo+input:analog-stereo\"}
else
    pw-cli s alsa_card.pci-0000_00_1b.0 Spa:Enum:ParamId:Profile {name:\"output:iec958-stereo+input:analog-stereo\"}
fi
WP_ID=$(wpctl status -n |grep -m1 alsa_output.pci-0000_00_1b.0 | sed 's/.* \([0-9]\+\). .*/\1/')
wpctl set-default $WP_ID
wpctl status

