#!/bin/bash

# This script uploads new firmware to the Pico.
# You need to provide the .elf file, not the .uf2
# run as root!

# Force script to exit if an error occurs
set -e

if [[ -f /etc/openmoweros_version ]]
then
    echo ""
    echo " [✓] OpenMowerOS detected"
    echo ""
else
    echo ""
    echo "ERROR: OpenMowerOS not detected!"
    echo "This script is only supported on OpenMowerOS"
    echo ""
    exit 1
fi

if [[ ! -d /sys/class/gpio/gpio10/ ]]
then
  echo "10" > /sys/class/gpio/export
fi
echo "out" > /sys/class/gpio/gpio10/direction
echo "1" > /sys/class/gpio/gpio10/value
openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program $1 verify reset exit"
if [[ -d /sys/class/gpio/gpio10/ ]]
then
  echo "10" > /sys/class/gpio/unexport
fi
