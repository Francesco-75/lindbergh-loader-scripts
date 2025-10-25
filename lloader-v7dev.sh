#!/bin/bash
set -e

# Colore oro: RGB 255,215,0
GOLD='\e[38;2;255;215;0m'
GREEN='\e[38;2;0;255;0m'
RED='\e[38;2;255;0;0m'
RESET='\e[0m'

echo -e "${GOLD}****************************************************************************"
echo -e "${GOLD}*  ██╗     ██╗███╗   ██╗██████╗ ██████╗ ███████╗██████╗  ██████╗ ██╗  ██╗  *"
echo -e "${GOLD}*  ██║     ██║████╗  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝ ██║  ██║  *"
echo -e "${GOLD}*  ██║     ██║██╔██╗ ██║██║  ██║██████╔╝█████╗  ██████╔╝██║  ███╗███████║  *"
echo -e "${GOLD}*  ██║     ██║██║╚██╗██║██║  ██║██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██║  *"
echo -e "${GOLD}*  ███████╗██║██║ ╚████║██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║  ██║  *"
echo -e "${GOLD}*  ╚══════╝╚═╝╚═╝  ╚═══╝╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝  *"
echo -e "${GOLD}*                                                                          *"
echo -e "${GOLD}*         ${GREEN}Welcome to the Automated Package Installer${RESET}${GOLD} ${RED}by Francesco-75${RESET}${GOLD}       *"
echo -e "${GOLD}*                  ${GREEN}Now it's Lindbergh Loader 2.1.x compliant${RESET}${GOLD}               *"
echo -e "${GOLD}*                   ${GREEN}Installing required packages...${RESET}${GOLD}                        *"
echo -e "${GOLD}*                                                                          *"
echo -e "${GOLD}****************************************************************************${RESET}"

# Add current user to dialout and input groups
target_user="${SUDO_USER:-$USER}"
echo "Adding user $target_user to groups dialout and input..."
sudo usermod -a -G dialout,input "$target_user"

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

# Inline install-packages.sh
echo "Running package installation..."
sudo dpkg --add-architecture i386
sudo apt update

# Ensure only fuse3 is used (remove legacy fuse if present)
sudo apt-get purge -y fuse || true

sudo apt -y install --no-install-recommends \
  build-essential gcc-multilib g++-multilib cmake fuse3 freeglut3-dev:i386 libvdpau1:i386 libstdc++5:i386 libxmu6:i386 \
  libpcsclite1:i386 libncurses5:i386 unzip libsndio-dev libsndio-dev:i386 pulseaudio-utils:i386 zlib1g:i386 libgpg-error0:i386 \
  libasound2 libasound2-dev libasound2:i386 libasound2-dev:i386 libfreetype6-dev:i386 libdbus-1-dev libpulse-dev libdbus-1-dev:i386 \
  libudev-dev:i386 libxcursor-dev:i386 libxfixes-dev:i386 libxi-dev:i386 libxrandr-dev:i386 libxss-dev:i386 libxxf86vm-dev:i386 git libvulkan1:i386 \
  mesa-vulkan-drivers:i386

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

# Install base PipeWire packages so the audio card is detected on Ubuntu 22.04
sudo apt install -y pipewire pipewire-audio-client-libraries wireplumber

sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

echo "Cloning the Lindbergh Loader repository..."
git clone https://github.com/lindbergh-loader/lindbergh-loader.git

cd lindbergh-loader

# Inline build-deps.sh
APPIMAGEDIRNAME=lindbergh-loader-dev.AppDir
OUTPUT_FOLDER=$(realpath "./$APPIMAGEDIRNAME")

mkdir -p build-deps
cd build-deps

# Build SDL3
git clone https://github.com/libsdl-org/SDL.git
cd SDL
mkdir build
cd build
cmake ../ -DCMAKE_C_FLAGS=-m32 -DCMAKE_INSTALL_PREFIX=/usr
make -j4
sudo make install
cd ../../

# Build SDL3_ttf
git clone https://github.com/libsdl-org/SDL_ttf.git
cd SDL_ttf
mkdir build
cd build
cmake ../ -DCMAKE_C_FLAGS=-m32 -DCMAKE_INSTALL_PREFIX=/usr
make -j4
sudo make install
cd ../../

# Build SDL3_image
git clone https://github.com/libsdl-org/SDL_image.git
cd SDL_image
mkdir build
cd build
cmake ../ -DCMAKE_C_FLAGS=-m32 -DCMAKE_INSTALL_PREFIX=/usr
make -j4
sudo make install
cd ../../

# Build libFAudio
git clone https://github.com/FNA-XNA/FAudio.git
cd FAudio
mkdir build
cd build
cmake ../ -DCMAKE_C_FLAGS=-m32 -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=off
make -j4
sudo make install
cd ../../../  # This returns to repo root (lindbergh-loader)

# (Removed the extra: cd ..  which was causing us to leave the repo)

echo "Building and installing Lindbergh Loader..."
make

# Create config and controls using the executable from build directory
if [ -f "build/lindbergh" ]; then
    echo "Creating default config with build/lindbergh..."
    ( cd build && ./lindbergh --create config )
    echo "Creating default controls with build/lindbergh..."
    ( cd build && ./lindbergh --create controls )
elif [ -f "./lindbergh" ]; then
    echo "Fallback: executable found in repo root."
    ./lindbergh --create config
    ./lindbergh --create controls
else
    echo "Warning: lindbergh executable not found in build/ nor in root."
fi

# Le seguenti righe aprivano automaticamente la cartella dopo il build.
# Sono ora commentate per disabilitare il popup dopo 'make'.
# Per riattivare, decommenta le righe qui sotto.
# echo "Opening the build directory..."
# cd ..
# xdg-open "$(pwd)/lindbergh-loader/build" &

# Install Theme
REPO_URL="https://github.com/Francesco-75/lindbergh-plymouth.git"
REPO_DIR="$HOME/Downloads/lindbergh-plymouth"
BACKGROUND_IMAGE="$REPO_DIR/loader-background.png"
DEST_DIR="$HOME/Pictures"
IMAGE_PATH="$HOME/Pictures/loader-background.png"

if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning theme repository..."
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "Theme repository already exists. Pulling latest changes..."
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

# Install gnome-control-center
echo "Installing gnome-control-center..."
sudo apt install -y gnome-control-center

# Disable brltty services
echo "Disabling brltty services..."
sudo systemctl stop brltty-udev.service || true
sudo systemctl mask brltty-udev.service || true
sudo systemctl stop brltty.service || true
sudo systemctl disable brltty.service || true

# Show patreon message just before reboot
echo -e "${GOLD}*********************************************************************************"
echo "*            If you found this software useful, consider supporting it!         *"
echo "*                https://patreon.com/LindberghLoader                            *"
echo -e "*********************************************************************************${RESET}"

echo -e "${GOLD}*********************************************************************************"
echo "*          All packages installed and Lindbergh Loader built successfully!      *"
echo -e "*********************************************************************************${RESET}"

# Confirm before reboot
echo ""
read -p "The system will reboot in 10 seconds. Press Ctrl+C to cancel or Enter to continue..." -t 10 || true

for i in {10..1}
do
    echo "Rebooting in $i seconds..."
    sleep 1
done

echo "Rebooting now!"
sudo reboot
