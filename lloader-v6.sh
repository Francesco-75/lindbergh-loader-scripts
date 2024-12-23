#!/bin/bash

echo "****************************************************************************"
echo "*  ██╗     ██╗███╗   ██╗██████╗ ██████╗ ███████╗██████╗  ██████╗ ██╗  ██╗  *"
echo "*  ██║     ██║████╗  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝ ██║  ██║  *"
echo "*  ██║     ██║██╔██╗ ██║██║  ██║██████╔╝█████╗  ██████╔╝██║  ███╗███████║  *"
echo "*  ██║     ██║██║╚██╗██║██║  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██║  *"
echo "*  ███████╗██║██║ ╚████║██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║  ██║  *"
echo "*  ╚══════╝╚═╝╚═╝  ╚═══╝╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝  *"
echo "*                                                                          *"
echo "*        ██╗      ██████╗  █████╗ ██████╗ ███████╗██████╗                  *"
echo "*        ██║     ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗                 *"
echo "*        ██║     ██║   ██║███████║██║  ██║█████╗  ██████╔╝                 *"
echo "*        ██║     ██║   ██║██╔══██║██║  ██║██╔══╝  ██╔══██╗                 *"
echo "*        ███████╗╚██████╔╝██║  ██║██████╔╝███████╗██║  ██║                 *"
echo "*        ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝                 *"
echo "*                                                                          *"
echo "*           Welcome to the Automated Package Installer                     *"
echo "*                                                                          *"
echo "*                   Installing required packages...                        *"
echo "*                                                                          *"
echo "****************************************************************************"

# Ask if the user uses an Intel/AMD GPU
read -p "Do you use an Intel/AMD GPU? (yes/no): " user_response

if [[ "$user_response" == "yes" || "$user_response" == "y" ]]; then
    echo "You use an Intel GPU. Proceeding with the necessary PPA and upgrade..."
    
    # Add Intel-specific PPA and update system
    sudo add-apt-repository ppa:kisak/kisak-mesa
    sudo apt update
    sudo apt upgrade -y
else
    echo "No Intel GPU detected. Skipping Intel-specific setup."
fi

# Add current user to dialout and input groups
echo "Adding user $USER to dialout and input groups..."
sudo usermod -a -G dialout,input $USER

# Add i386 architecture
sudo dpkg --add-architecture i386

# Update package list
sudo apt update

# Install Git if not already installed
echo "Checking if Git is installed..."
if ! command -v git &> /dev/null; then
    echo "Git not found, installing Git..."
    sudo apt install -y git
else
    echo "Git is already installed."
fi

# Install necessary packages
#sudo apt install -y gcc-multilib
sudo dpkg --add-architecture i386
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y build-essential
sudo apt install -y freeglut3:i386
sudo apt install -y freeglut3-dev:i386
sudo apt install -y libglew-dev
sudo apt install -y xorg-dev
sudo apt install -y libopenal1:i386 libopenal-dev:i386
sudo apt install -y libxmu6:i386
sudo apt install -y libstdc++5:i386
sudo apt-get install -y gcc-multilib g++-multilib
sudo apt install -y libsdl2-dev:i386
sudo apt install -y libfaudio0:i386
sudo apt install -y libfaudio-dev:i386
sudo apt-get install -y libncurses5:i386
sudo apt install -y libasound2-dev:i386
sudo apt install -y alsa-utils:i386
sudo apt-get install -y libasound2-plugins:i386

# Clone the Lindbergh Loader repository
echo "Cloning the Lindbergh Loader repository..."
git clone https://github.com/lindbergh-loader/lindbergh-loader.git

# Change directory to the cloned repository
cd lindbergh-loader

# Build and install Lindbergh Loader
echo "Building and installing Lindbergh Loader..."
make

# Open the build directory in the file manager
echo "Opening the build directory..."
cd ..
xdg-open "$(pwd)/lindbergh-loader/build" &

# Final Banner for Patreon/Donation
echo "*********************************************************************************"
echo "*                                                                               *"
echo "*            If you found this software useful, consider supporting it!         *"
echo "*                                                                               *"
echo "*            You can donate or support via Patreon:                             *"
echo "*                     https://patreon.com/LindberghLoader                       *"
echo "*                                                                               *"
echo "*           Any contributions are greatly appreciated to keep development       *"
echo "*           going and improve future projects!                                  *"
echo "*                                                                               *"
echo "*********************************************************************************"

# Completion message
echo "*********************************************************************************"
echo "*                                                                               *"
echo "*          All packages installed and Lindbergh Loader built successfully!      *"
echo "*                                                                               *"
echo "*********************************************************************************"

# Install Theme

echo "****************************************************************************"
echo "*                                                                          *"
echo "*           Welcome to the Lindbergh Plymouth Theme Installer              *"
echo "*                                                                          *"
echo "*                   Installing required packages...                        *"
echo "*                                                                          *"
echo "****************************************************************************"

# Define the target directories and the URL of the repository
REPO_URL="https://github.com/Francesco-75/lindbergh-plymouth.git"
REPO_DIR="$HOME/Downloads/lindbergh-plymouth"
BACKGROUND_IMAGE="$REPO_DIR/loader-background.png"
DEST_DIR="$HOME/Pictures"  # Correctly use the $HOME variable for the Pictures directory
IMAGE_PATH="$HOME/Pictures/loader-background.png"

# Step 1: Clone the repository
if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "Repository already exists. Pulling latest changes..."
  cd "$REPO_DIR" && git pull
fi

# Step 2: Check if the background image exists and copy it
if [ -f "$BACKGROUND_IMAGE" ]; then
  echo "Copying the background image to $DEST_DIR..."
  cp "$BACKGROUND_IMAGE" "$DEST_DIR"
else
  echo "Error: $BACKGROUND_IMAGE does not exist!"
  exit 1
fi

echo "Operation completed successfully."

# Set the background using gsettings (for GNOME desktop environment)
gsettings set org.gnome.desktop.background picture-uri "file://$IMAGE_PATH"

# Provide feedback to the user
echo "Desktop background changed successfully to $IMAGE_PATH"

# Display countdown
for i in {10..1}
do
    echo "Rebooting in $i seconds..."
    sleep 1
done

# Reboot the system
echo "Rebooting now!"
sudo reboot

