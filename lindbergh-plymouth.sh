#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run as root. Re-running with sudo..."
  # Re-run the script with sudo
  sudo "$0" "$@"
  exit 0
fi

# Install necessary dependencies if they are not already installed
apt update && apt install -y git plymouth plymouth-themes

# Clone the repository
cd /tmp
git clone https://github.com/Francesco-75/lindbergh-plymouth.git

# Move the theme to the correct directory
mkdir -p /usr/share/plymouth/themes/lindbergh
cp -r /tmp/lindbergh-plymouth/* /usr/share/plymouth/themes/lindbergh/

# Set the theme as default (with a priority of 100)
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/lindbergh/lindbergh.plymouth 100

# Automatically select the lindbergh.plymouth theme by sending input to the update-alternatives command
echo "2" | update-alternatives --config default.plymouth

# Update initramfs to apply the changes
update-initramfs -u

# Clean up by removing the temporary clone
rm -rf /tmp/lindbergh-plymouth

echo "Installation complete..."

# Display countdown
for i in {10..1}
do
    echo "Rebooting in $i seconds..."
    sleep 1
done

# Reboot the system
echo "Rebooting now!"
sudo reboot
