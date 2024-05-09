#!/bin/bash

# Force script to exit if an error occurs
set -e


SRC_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"


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


echo ""
echo "Updating the scripts..."
echo ""
  cd "${SRC_DIR}"
  git fetch --all && git reset --hard origin/HEAD
echo ""
echo "...done"
echo ""