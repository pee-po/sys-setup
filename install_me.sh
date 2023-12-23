#!/usr/bin/env bash

# Personall bootstrap system script
#===============================================================
# █████                     █████              ████  ████ 
#░░███                     ░░███              ░░███ ░░███ 
# ░███  ████████    █████  ███████    ██████   ░███  ░███ 
# ░███ ░░███░░███  ███░░  ░░░███░    ░░░░░███  ░███  ░███ 
# ░███  ░███ ░███ ░░█████   ░███      ███████  ░███  ░███ 
# ░███  ░███ ░███  ░░░░███  ░███ ███ ███░░███  ░███  ░███ 
# █████ ████ █████ ██████   ░░█████ ░░████████ █████ █████
#░░░░░ ░░░░ ░░░░░ ░░░░░░     ░░░░░   ░░░░░░░░ ░░░░░ ░░░░░

#                             ███             █████   
#                            ░░░             ░░███    
#  █████   ██████  ████████  ████  ████████  ███████  
# ███░░   ███░░███░░███░░███░░███ ░░███░░███░░░███░   
#░░█████ ░███ ░░░  ░███ ░░░  ░███  ░███ ░███  ░███    
# ░░░░███░███  ███ ░███      ░███  ░███ ░███  ░███ ███
# ██████ ░░██████  █████     █████ ░███████   ░░█████ 
#░░░░░░   ░░░░░░  ░░░░░     ░░░░░  ░███░░░     ░░░░░  
#                                  ░███               
#                                  █████              
#                                 ░░░░░
#===============================================================


# Purpose and requirements
# ==============================================================
# This is a bash script that allows me to quickly reinstall my
# system. It comes with no guarantee - it's only tested against
# my distro of choice (currently mint), and barely even that.
# It is not actively maintained to newest software - I only
# tinker with it when the need arises. Nevertheless, feel free
# to take inspiration and give feedback.
#
# apt and apt-get are required. Xterm is assumed to be the
# default terminal.

# Things to review
# ==============================================================
# Before running the script:
# * Nerdfont release version
# * JDK version
# * Valgrind version
# * List of codium extensions
#
# After running the script:
# * Set up nerd font in terminal
# * Setup git config - name, default text editor, ssh
# * Make sure that bash_aliases is sourced in bashrc
#   (this is the case for mint, maybe not so for ubuntu or debian)
# * Login to vpn
# * Install RStudio from .deb
# * Install ProtonGE https://github.com/GloriousEggroll/proton-ge-custom
# * Install Steam, Lutris
# * Darkmode :)
# * Make sure keyboard layout is set right
# * Install NVidia drivers and top it up with mesa-vulkan-drivers:i386

# Running
# ==============================================================
# wget -q -O - \
# https://raw.githubusercontent.com/pee-po/sys-setup/master/install_me.sh \
# sudo bash

# Parameters
# ==============================================================
# Extensions for codium that will be autoinstalled
codium_extensions=(
    ms-python.isort
    ms-python.python
    ms-vscode.cmake-tools
    ms-vscode.cpptools-themes
    ms-vscode.hexeditor
    franneck94.vscode-c-cpp-dev-extension-pack
)

# TODOS:
# ==============================================================
# * Add parameters for versions that need to be reviewed
# * Add ProtonGE installation script
# * Add check for root user
# * Add prompt reminding what to do after
# * Fix flathub installs

# Basics
# ==============================================================
# Basic tools needed for the setup, fonts, etc.

apt update
apt install -y \
    wget \
    gpg \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    dirmngr \
    git \
    cmake \
    npm \
    openjdk-19-jdk \
    python3-pip \
    xclip \
    vim

# Setup python and npm for neovim
sudo -u $SUDO_USER pip3 install neovim
npm install -g neovim

UHOME=/home/$SUDO_USER
DPWD=$(pwd)
TMP_DIR=/tmp/install_tmp
mkdir -p $TMP_DIR

# Install Nerd Font
wget \
https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip \
-O $TMP_DIR/Hack.zip
unzip $TMP_DIR/Hack.zip -d $TMP_DIR/Hack
mv $TMP_DIR/Hack/*.ttf /usr/share/fonts
fc-cache -fv

# Packages built from source
# ==============================================================

# Neovim
# System version is to old, needs building from source
mkdir -p $TMP_DIR/neovim
git clone https://github.com/neovim/neovim.git $TMP_DIR/neovim
make CMAKE_BUILD_TYPE=Release -C $TMP_DIR/neovim
make install -C $TMP_DIR/neovim
chmod a+x /usr/local/bin/nvim

# Valgrind
VALGRIND_VER=3.22.0
wget https://sourceware.org/pub/valgrind/valgrind-$VALGRIND_VER.tar.bz2 \
    -O $TMP_DIR/valgrind-$VALGRIND_VER.tar.bz2
tar -xjf $TMP_DIR/valgrind-$VALGRIND_VER.tar.bz2 -C $TMP_DIR
cd $TMP_DIR/valgrind-$VALGRIND_VER
./configure
make
make install
cd $DPWD


# Setup dotfiles
# ==============================================================
# Since this is ment to be run as root, it needs some
# workarounds for user and home dir.
sudo -u $SUDO_USER \
    git clone --bare https://github.com/pee-po/dotfiles.git $UHOME/.cfg
alias config='/usr/bin/git --git-dir=$UHOME/.cfg/ --work-tree=$UHOME'
mkdir -p $UHOME/.config-backup && \
	sudo -u $SUDO_USER config checkout 2>&1 | egrep "\s+\." | \
    awk {'print $1'} | \
    sudo -u $SUDO_USER xargs -I{} mv {} $UHOME/.config-backup/{}
chown -R $SUDO_USER:$SUDO_USER $UHOME/.config-backup
sudo -u $SUDO_USER /usr/bin/git --git-dir=$UHOME/.cfg/ \
    --work-tree=$UHOME checkout
sudo -u $SUDO_USER /usr/bin/git --git-dir=$UHOME/.cfg/ \
    --work-tree=$UHOME config --local status.showUntrackedFiles no

# Sync nvim
sudo -u $SUDO_USER nvim --headless \
    -c 'autocmd User PackerComplete quitall' \
    -c 'PackerSync'

# Other Packages
# ==============================================================
# Repositories

# Codium
wget -qO - \
https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
| gpg --dearmor \
|  dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | tee /etc/apt/sources.list.d/vscodium.list

# Wine
mkdir -pm755 /etc/apt/keyrings
wget -O \
    /etc/apt/keyrings/winehq-archive.key \
    https://dl.winehq.org/wine-builds/winehq.key
wget -NP \
    /etc/apt/sources.list.d/ \
    https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources

#NordVPN
NVPN_BASE_URL=https://repo.nordvpn.com
NVPN_KEY_PATH=/gpg/nordvpn_public.asc
NVPN_REPO_PATH_DEB=/deb/nordvpn/debian
NVPN_RELEASE="stable main"
NVPN_PUB_KEY=${NVPN_BASE_URL}${NVPN_KEY_PATH}
NVPN_REPO_URL_DEB=${NVPN_BASE_URL}${NVPN_REPO_PATH_DEB}

wget -qO - "${NVPN_PUB_KEY}" | \
    tee /etc/apt/trusted.gpg.d/nordvpn_public.asc > /dev/null
echo "deb ${NVPN_REPO_URL_DEB} ${NVPN_RELEASE}" | tee /etc/apt/sources.list.d/nordvpn.list

# Install packages from repos
apt update
apt install -y \
    r-base \
    r-base-dev \
    keepassxc \
    vlc \
    codium \
    gimp \
    p7zip \
    qbittorrent \
    codium \
    mono-complete \
    nordvpn

apt install --install-recommends winehq-stable

# Something's fucky
# flatpak install flathub -y org.ferdium.Ferdium
# flatpak install flathub -y com.discordapp.Discord


# Install packages from web
# Miniforge - conda, mamba
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -O $TMP_DIR/Miniforge.sh
bash $TMP_DIR/Miniforge.sh -b -p /usr/local/miniforge3
ln -s /usr/local/miniforge3/bin/* /usr/local/bin

# tex
wget -O $TMP_DIR/install-tl-unx.tar.gz \
	https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat $TMP_DIR/install-tl-unx.tar.gz | tar xf - -C $TMP_DIR
TLDIR=$(ls $TMP_DIR/ -a | grep -E "install-tl-[0-9]{8}" | head -1)
perl $TMP_DIR/$TLDIR/install-tl --no-interaction
TLYEAR=$(echo $TLDIR | grep -oP "[0-9]{4}(?=[0-9]{4})")
TLPLATFORM=$(ls /usr/local/texlive/$TLYEAR/bin | head -1)
echo 'export PATH="/usr/local/texlive/$TLYEAR/bin/$TLPLATFORM:$PATH"' \
    >> ~/.bashrc

# Codium extensions
for i in "${codium_extensions[@]}"; do
    sudo -u $SUDO_USER codium --install-extension $i
done

apt update
apt upgrade -y

# Setup keyfile for disk encrytion based on nixCraft's article (see README)
KEYFILE=/etc/backup_keyfile
dd bs=512 count=4 if=/dev/random of=$KEYFILE iflag=fullblock
openssl genrsa -out $KEYFILE 4096
chmod -v 0400 $KEYFILE
chown root:root $KEYFILE

