#!/bin/bash

# Force script to exit if an error occurs
set -e

# Source core functions
source $HOME/openmoweros-tools/.core.sh

get_source_dir

FW_URL_BASE="https://github.com/xtech/fw-xcore-boot"
FW_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' $FW_URL_BASE/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
FW_URL="$FW_URL_BASE/releases/download/$FW_LATEST_VERSION/xcore-boot-$FW_LATEST_VERSION"
LOCAL_FW_FILE="$HOME/xcore-boot.elf"

check_euid

#check_openmoweros

#if [[ -z "${OM_HARDWARE_VERSION}" ]]
#then
#  echo ""
#  echo "ERROR: "OM_HARDWARE_VERSION" is not specified"
#  echo "Please configure it at /boot/openmower/mower_config.txt before running this script again!"
#  echo ""
#  exit 1
#fi

function download_fw() {
  echo ""
  echo "Downloading latest xcore-boot from \"$FW_URL_BASE\":"
  echo ""
  wget --no-verbose --show-progress -O $HOME/xcore-boot.zip ${FW_URL}.zip
}

function flash_bootloader() {
  openocd -f interface/xcore.cfg -f target/stm32h7x.cfg -c "program $LOCAL_FW_FILE verify reset exit"

}

#if [[ -s $HOME/xcore-boot.zip ]]
#then
#  echo ""
#  echo "Cached firmware.zip found."
#  echo "Comparing checksum with latest one from GitHub:"
#  echo ""
#  wget --no-verbose -O /tmp/firmware.sha256 ${FW_URL}.sha256
#  if sha256sum --check --status /tmp/firmware.sha256
#  then
#    echo " └> Cached firmware.zip hash matches."
#  else
#    echo " └> Cached firmware.zip hash differs."
#    download_fw
#  fi
#else
#    echo "No cached firmware.zip found."
  download_fw
#fi

echo ""
echo "Extrating firmware for \"$OM_HARDWARE_VERSION\""
echo ""
unzip -o -p $HOME/xcore-boot.zip artifacts/bootloader/xcore-boot.elf > $LOCAL_FW_FILE
echo ""
echo "Executing flash script with firmware \"$FW_FILE\":"
echo ""
#sudo $SRC_DIR/upload_firmware.sh $LOCAL_FW_FILE
flash_bootloader

success_msg
