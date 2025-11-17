#!/bin/sh
# NVIDIA Driver Installation and Xorg Configuration Script for Arch Linux
# Installs appropriate NVIDIA drivers, configures kernel modules, sets up early loading, and configures Xorg

if [ "$(id -u)" -eq 0 ]; then
    echo "Don't run this script as root. Run as your regular user."
    exit 1
fi

if [ -n "$(lspci | grep -i 'nvidia')" ]; then
    echo "NVIDIA GPU detected:"
    lspci | grep -i 'nvidia'
    
    if echo "$(lspci | grep -i 'nvidia')" | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
        NVIDIA_DRIVER_PACKAGE="nvidia-open"
        echo "Using open-source NVIDIA drivers"
    else
        NVIDIA_DRIVER_PACKAGE="nvidia"
        echo "Using proprietary NVIDIA drivers"
    fi
else
    echo "No NVIDIA GPU detected. Exiting."
    exit 0
fi

KERNEL_HEADERS="linux-headers"
if pacman -Q linux-zen >/dev/null 2>&1; then
    KERNEL_HEADERS="linux-zen-headers"
elif pacman -Q linux-lts >/dev/null 2>&1; then
    KERNEL_HEADERS="linux-lts-headers"
elif pacman -Q linux-hardened >/dev/null 2>&1; then
    KERNEL_HEADERS="linux-hardened-headers"
fi

if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling multilib repository for 32-bit support..."
    sudo sed -i '/^#\s*\[multilib\]/,/^#\s*Include/ s/^#\s*//' /etc/pacman.conf
    sudo pacman -Sy
fi

PACKAGES_TO_INSTALL=(
    "$KERNEL_HEADERS"
    "$NVIDIA_DRIVER_PACKAGE"
    "nvidia-utils"
    "nvidia-settings"
    "lib32-nvidia-utils"
    "libva-nvidia-driver"
)

sudo pacman -S --needed --noconfirm "${PACKAGES_TO_INSTALL[@]}"

# Backup existing modprobe config if it exists
if [ -f /etc/modprobe.d/nvidia.conf ]; then
    sudo cp /etc/modprobe.d/nvidia.conf /etc/modprobe.d/nvidia.conf.backup
fi

echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
echo "options nvidia preserve_video_memory_allocations=1" | sudo tee -a /etc/modprobe.d/nvidia.conf >/dev/null

MKINITCPIO_CONF="/etc/mkinitcpio.conf"
NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

sudo cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
sudo sed -i -E 's/\bnvidia(_drm|_uvm|_modeset)?\b//g' "$MKINITCPIO_CONF"
sudo sed -i -E "s/^(MODULES=\\()[^)]*/\\1$NVIDIA_MODULES /" "$MKINITCPIO_CONF"
sudo sed -i -E 's/  +/ /g; s/\\( /\\(/g' "$MKINITCPIO_CONF"

sudo mkinitcpio -P

echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf >/dev/null

echo ""
echo "Configuring Xorg..."

sudo mkdir -p /etc/X11/xorg.conf.d

# NVIDIA Xorg configuration with performance options
sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf >/dev/null << 'EOF'
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    VendorName "NVIDIA Corporation"
    Option "TripleBuffer" "on"
    Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
    Option "ThreadedOptimizations" "on"
    Option "MaxFramesAllowed" "1"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "NVIDIA Card"
    Monitor "Monitor0"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
    EndSubSection
EndSection
EOF

# NVIDIA environment variables
sudo tee /etc/environment.d/10-nvidia.conf >/dev/null << 'EOF'
LIBVA_DRIVER_NAME=nvidia
NVD_BACKEND=direct
EOF

echo ""
echo "NVIDIA drivers and Xorg configuration complete!"
echo "Reboot to activate drivers and load kernel modules."
