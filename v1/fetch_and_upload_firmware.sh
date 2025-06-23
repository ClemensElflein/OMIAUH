#!/bin/bash

# Force script to exit if an error occurs
set -e

# Source core functions
source $HOME/openmoweros-tools/.core.sh

get_source_dir

FW_URL_BASE="https://github.com/ClemensElflein/OpenMower"
FW_URL="$FW_URL_BASE/releases/download/latest/firmware"
LOCAL_FW_FILE="$HOME/firmware.elf"

check_euid

check_openmoweros

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
  echo ""
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

echo ""
echo "Extrating firmware for \"$OM_HARDWARE_VERSION\""
echo ""
unzip -o -p $HOME/firmware.zip firmware/$OM_HARDWARE_VERSION/firmware.elf > $LOCAL_FW_FILE
echo ""
echo "Executing flash script with firmware \"$LOCAL_FW_FILE\":"
sudo $SRC_DIR/upload_firmware.sh $LOCAL_FW_FILE

success_msg
