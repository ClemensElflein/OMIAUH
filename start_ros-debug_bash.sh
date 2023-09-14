#!/bin/bash

# Starts a bash in the container.
# Use this for ROS specific commands (e.g. rostopic echo)

sudo podman exec -it openmower-debug /openmower_entrypoint.sh ${@:-/bin/bash}
