#!/bin/sh
# Execute like:
# sudo ./setup_node.sh
# or for master node
# sudo ./setup_node.sh master

# Set current working directory to script directory
cd "$(dirname "$0")"

# Update system
apt-get update
apt-get upgrade -y

# Expand filesystem
raspi-config nonint do_expand_rootfs

# Copy default configuration and overwrite existing one
cp -rf resources/config.txt /boot/

# Copy SSH file toggle
cp -rf resources/ssh /boot/

# MASTER NODE INSTRUCTIONS
if [ $# -ge 1 ] && [ $1 = "master" ]; then
   # Install for "pip3" support
   apt-get install python3-pip -y

   # Install for Adafruit compatibility
   pip3 install RPi.GPIO
   
   # Install Adafruit support for LCD screen, use it for displaying master node IP
   pip3 install adafruit-charlcd

   # Prepare utility directory
   [ -d /utils ] || mkdir /utils
   
   # Prepare LCD utility script
   cp resources/LCD.py /utils/

   # Make a backup of rc.local
   mv /etc/rc.local /etc/rc.local.bak
   
   # Supply own rc.local for starting at boot
   cp resources/rc.local /etc/
   
   # Assign permissions
   chmod +x /etc/rc.local
fi

# Reboot
#shutdown -r now
