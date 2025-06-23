#!/bin/sh

# This script starts OpenOCD on the pi and allows external connections.
# This way you can use VS code to remotely debug the Pico code.

openocd -f interface/xcore.cfg -f target/stm32h7x.cfg -c "bindto 0.0.0.0"

