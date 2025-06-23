#!/bin/bash

# This script uploads new firmware to the Pico.
# You need to provide the .elf file, not the .uf2
# run as root!

# Force script to exit if an error occurs
set -e

# Source core functions
source $HOME/openmoweros-tools/.core.sh

check_openmoweros

if command -v pinctrl 2>&1 >/dev/null; then
  pinctrl set 10 op dh
elif [[ -e /sys/class/gpio/gpio10 ]]; then
  echo "10" > /sys/class/gpio/export
  echo "out" > /sys/class/gpio/gpio10/direction
  echo "1" > /sys/class/gpio/gpio10/value
else
  echo ""
  echo "WARNING: could not find a method to set RPI power gpio"
  echo ""
fi
openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program $1 verify reset exit"
