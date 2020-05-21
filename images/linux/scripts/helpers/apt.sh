#!/bin/bash
################################################################################
##  File:  apt.sh
##  Desc:  This script contains helper functions for using dpkg and apt
################################################################################

## Use dpkg to figure out if a package has already been installed
## Example use:
## if ! IsInstalled packageName; then
##     echo "packageName is not installed!"
## fi
function IsInstalled {
    dpkg -S $1 &> /dev/null
}

# Configure apt to always assume Y
if [ ! -f /etc/apt/apt.conf.d/90assumeyes ]; then
    echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes
fi

