#!/bin/bash

echo "****************************************************************************"
echo "*  ██╗     ██╗███╗   ██╗██████╗ ██████╗ ███████╗██████╗  ██████╗ ██╗  ██╗  *"
echo "*  ██║     ██║████╗  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝ ██║  ██║  *"
echo "*  ██║     ██║██╔██╗ ██║██║  ██║██████╔╝█████╗  ██████╔╝██║  ███╗███████║  *"
echo "*  ██║     ██║██║╚██╗██║██║  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██║  *"
echo "*  ███████╗██║██║ ╚████║██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║  ██║  *"
echo "*  ╚══════╝╚═╝╚═╝  ╚═══╝╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝  *"
echo "*                                                                          *"
echo "*           Welcome to the Automated Package Installer                     *"
echo "*                                                                          *"
echo "*                   Installing required packages...                        *"
echo "*                                                                          *"
echo "****************************************************************************"

# (RIMOSSO: prompt Intel/AMD GPU)

echo "Adding user $USER to dialout and input groups..."
sudo usermod -a -G dialout,input $USER

sudo dpkg --add-architecture i386
sudo apt update

echo "Checking if Git is installed..."
if ! command -v git &> /dev/null; then
    echo "Git not found, installing Git..."
    sudo apt install -y git
else
    echo "Git is already installed."
fi

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
sudo apt install -y pipewire-audio-client-libraries:i386
sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

echo "Cloning the Lindbergh Loader repository..."
git clone https://github.com/lindbergh-loader/lindbergh-loader.git

cd lindbergh-loader

# Esecuzione script appimage prima del make
if [ -f "scripts/appimage/install-packages.sh" ] && [ -f "scripts/appimage/build-deps.sh" ]; then
    echo "Running pre-build scripts (install-packages.sh & build-deps.sh)..."
    chmod +x scripts/appimage/install-packages.sh scripts/appimage/build-deps.sh 2>/dev/null
    ( cd scripts/appimage && ./install-packages.sh && ./build-deps.sh )
else
    echo "One or both required scripts not found in scripts/appimage/. Continuo comunque..."
fi

echo "Building and installing Lindbergh Loader..."
make

# Creazione config e controls usando l'eseguibile nella cartella build
if [ -f "build/lindbergh" ]; then
    echo "Creating default config with build/lindbergh..."
    ( cd build && ./lindbergh --create config )
    echo "Creating default controls with build/lindbergh..."
    ( cd build && ./lindbergh --create controls )
elif [ -f "./lindbergh" ]; then
    echo "Fallback: eseguibile trovato in root repo."
    ./lindbergh --create config
    ./lindbergh --create controls
else
    echo "Attenzione: eseguibile lindbergh non trovato né in build/ né nella root."
fi

echo "Opening the build directory..."
cd ..
xdg-open "$(pwd)/lindbergh-loader/build" &

echo "*********************************************************************************"
echo "*            If you found this software useful, consider supporting it!         *"
echo "*                https://patreon.com/LindberghLoader                            *"
echo "*********************************************************************************"

echo "*********************************************************************************"
echo "*          All packages installed and Lindbergh Loader built successfully!      *"
echo "*********************************************************************************"

# Install Theme
REPO_URL="https://github.com/Francesco-75/lindbergh-plymouth.git"
REPO_DIR="$HOME/Downloads/lindbergh-plymouth"
BACKGROUND_IMAGE="$REPO_DIR/loader-background.png"
DEST_DIR="$HOME/Pictures"
IMAGE_PATH="$HOME/Pictures/loader-background.png"

if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "Repository already exists. Pulling latest changes..."
  cd "$REPO_DIR" && git pull
fi

if [ -f "$BACKGROUND_IMAGE" ]; then
  echo "Copying the background image to $DEST_DIR..."
  cp "$BACKGROUND_IMAGE" "$DEST_DIR"
else
  echo "Error: $BACKGROUND_IMAGE does not exist!"
  exit 1
fi

echo "Operation completed successfully."

gsettings set org.gnome.desktop.background picture-uri "file://$IMAGE_PATH"
echo "Desktop background changed successfully to $IMAGE_PATH"

# Sezione aggiunta prima del reboot
echo "Installing gnome-control-center..."
sudo apt install -y gnome-control-center

echo "Disabilitazione servizi brltty..."
systemctl stop brltty-udev.service
sudo systemctl mask brltty-udev.service
systemctl stop brltty.service
systemctl disable brltty.service

for i in {10..1}
do
    echo "Rebooting in $i seconds..."
    sleep 1
done

echo "Rebooting now!"
sudo reboot
