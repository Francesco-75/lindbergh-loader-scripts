#!/bin/bash

# ASCII art message
echo "============================================="
echo "      Rename to eth0"
echo "============================================="
echo ""
echo "This script will back up your GRUB configuration, apply changes, and reboot."

# Backup the original /etc/default/grub file
backup_file="/etc/default/grub.bak_$(date +%Y%m%d%H%M%S)"
sudo cp /etc/default/grub "$backup_file"
echo "Backup created: $backup_file"

# Add the GRUB_CMDLINE_LINUX line to /etc/default/grub
echo 'GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"' | sudo tee -a /etc/default/grub > /dev/null

# Update GRUB configuration
sudo update-grub

# Countdown and reboot
echo "Rebooting in 10 seconds..."
for i in {10..1}
do
  echo "$i"
  sleep 1
done

# Reboot the system
sudo reboot

