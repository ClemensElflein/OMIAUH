#!/bin/bash

# Force script to exit if an error occurs
set -e


SRC_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
FW_URL_BASE="https://github.com/ClemensElflein/OpenMower"
FW_URL="$FW_URL_BASE/releases/download/latest/firmware"


if [[ ${EUID} -eq 0 ]]
then
    echo ""
    echo "ERROR: !! THIS SCRIPT MUST NOT RUN AS ROOT !!"
    echo "       It will ask for credentials as needed."
    echo ""
    exit 1
fi

if [[ -f /etc/openmoweros_version ]]
then
    echo ""
    echo " [✓] OpenMowerOS detected"
    echo ""
    source /boot/openmower/mower_config.txt
else
    echo ""
    echo "ERROR: OpenMowerOS not detected!"
    echo "This script is only supported on OpenMowerOS"
    echo ""
    exit 1
fi

if [[ -z "${OM_HARDWARE_VERSION}" ]]
then
    echo ""
    echo "ERROR: "OM_HARDWARE_VERSION" is not specified"
    echo "Please configure it at /boot/openmower/mower_config.txt before running this script again!"
    echo ""
    exit 1
fi

function download_fw() {
  echo ""
  echo "Downloading latest firmware.zip from \"$FW_URL_BASE\":"
  wget --no-verbose --show-progress -O $HOME/firmware.zip ${FW_URL}.zip
}


if [[ -s $HOME/firmware.zip ]]
then
    echo ""
    echo "Cached firmware.zip found."
    echo "Comparing checksum with latest one from GitHub:"
    echo ""
    wget --no-verbose -O /tmp/firmware.sha256 ${FW_URL}.sha256
    if sha256sum --check --status /tmp/firmware.sha256
    then
      echo " └> Cached firmware.zip hash matches."
    else
      echo " └> Cached firmware.zip hash differs."
      download_fw
    fi
else
    echo "No cached firmware.zip found."
    download_fw
fi

FW_FILE="$HOME/firmware.elf"
echo ""
echo "Extrating firmware for \"$OM_HARDWARE_VERSION\""
echo ""
unzip -o -p $HOME/firmware.zip firmware/$OM_HARDWARE_VERSION/firmware.elf > $FW_FILE
echo ""
echo "Executing flash script with firmware \"$FW_FILE\":"
sudo $SRC_DIR/upload_firmware.sh $FW_FILE

echo ""
echo " → Operation successfully completed 🎉"