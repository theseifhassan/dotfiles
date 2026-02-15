#!/bin/sh
# Hardware drivers
# shellcheck disable=SC2015  # A && B || C pattern is safe here (ok/fail never fail)

set -e

PKG="paru -S --needed --noconfirm"
command -v paru >/dev/null || PKG="sudo pacman -S --needed --noconfirm"

ok() { printf "\033[32m✓\033[0m %s\n" "$1"; }
fail() { printf "\033[31m✗\033[0m %s\n" "$1"; }

detect_kernel_headers() {
    pacman -Q linux-zen >/dev/null 2>&1 && echo "linux-zen-headers" && return
    pacman -Q linux-lts >/dev/null 2>&1 && echo "linux-lts-headers" && return
    echo "linux-headers"
}

check_nvidia() {
    lspci | grep -qi nvidia || { echo "No NVIDIA GPU"; return 0; }

    err=0

    # Core driver checks
    lsmod | grep -q "^nvidia " && ok "nvidia module loaded" || { fail "nvidia module not loaded"; err=1; }
    lsmod | grep -q "^nvidia_drm " && ok "nvidia_drm module loaded" || { fail "nvidia_drm not loaded"; err=1; }
    [ -f /etc/modprobe.d/nvidia.conf ] && ok "modprobe config exists" || { fail "/etc/modprobe.d/nvidia.conf missing"; err=1; }
    [ -f /etc/modprobe.d/blacklist-nouveau.conf ] && ok "nouveau blacklisted" || { fail "nouveau not blacklisted"; err=1; }
    grep -q "nvidia" /etc/mkinitcpio.conf && ok "nvidia in initramfs" || { fail "nvidia not in initramfs"; err=1; }
    command -v nvidia-smi >/dev/null && nvidia-smi >/dev/null 2>&1 && ok "nvidia-smi working" || { fail "nvidia-smi failed"; err=1; }

    [ $err -eq 0 ] && echo "NVIDIA: all good" || echo "NVIDIA: issues found"
}

check_bluetooth() {
    err=0
    pacman -Q bluez >/dev/null 2>&1 && ok "bluez installed" || { fail "bluez not installed"; err=1; }
    systemctl is-active --quiet bluetooth && ok "bluetooth service running" || { fail "bluetooth service not running"; err=1; }
    systemctl is-enabled --quiet bluetooth && ok "bluetooth service enabled" || { fail "bluetooth service not enabled"; err=1; }
    [ $err -eq 0 ] && echo "Bluetooth: all good" || echo "Bluetooth: issues found"
}

check_printer() {
    err=0
    pacman -Q cups >/dev/null 2>&1 && ok "cups installed" || { fail "cups not installed"; err=1; }
    systemctl is-active --quiet cups && ok "cups service running" || { fail "cups service not running"; err=1; }
    systemctl is-enabled --quiet cups && ok "cups service enabled" || { fail "cups service not enabled"; err=1; }
    groups "$USER" | grep -q lp && ok "user in lp group" || { fail "user not in lp group"; err=1; }
    [ $err -eq 0 ] && echo "Printer: all good" || echo "Printer: issues found"
}

check_virtualcam() {
    err=0
    pacman -Q v4l2loopback-dkms >/dev/null 2>&1 && ok "v4l2loopback installed" || { fail "v4l2loopback not installed"; err=1; }
    lsmod | grep -q "^v4l2loopback " && ok "v4l2loopback module loaded" || { fail "v4l2loopback not loaded"; err=1; }
    [ -e /dev/video10 ] && ok "/dev/video10 exists" || { fail "/dev/video10 missing"; err=1; }
    [ $err -eq 0 ] && echo "Virtual camera: all good" || echo "Virtual camera: issues found"
}

check_all() {
    check_nvidia; echo
    check_bluetooth; echo
    check_printer; echo
    check_virtualcam
}

install_nvidia() {
    lspci | grep -qi nvidia || { echo "No NVIDIA GPU"; return 0; }

    # Detect GPU generation for driver selection
    if lspci | grep -i nvidia | grep -qE "RTX [2-9][0-9]|GTX 16"; then
        DRIVER="nvidia-open"
    else
        DRIVER="nvidia"
    fi

    HEADERS=$(detect_kernel_headers)

    # Enable multilib for 32-bit libs
    grep -q "^\[multilib\]" /etc/pacman.conf || {
        sudo sed -i '/^#\s*\[multilib\]/,/^#\s*Include/ s/^#\s*//' /etc/pacman.conf
        sudo pacman -Syu --noconfirm
    }

    $PKG "$HEADERS" $DRIVER nvidia-utils nvidia-settings lib32-nvidia-utils libva-nvidia-driver || {
        echo "Retrying NVIDIA install..."
        sudo pacman -Syu --noconfirm
        $PKG "$HEADERS" $DRIVER nvidia-utils nvidia-settings lib32-nvidia-utils libva-nvidia-driver
    }

    # Kernel module options
    sudo mkdir -p /etc/modprobe.d
    cat <<'EOF' | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

    # Early loading in initramfs
    MODS="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
    sudo sed -i -E 's/ nvidia_drm//g; s/ nvidia_uvm//g; s/ nvidia_modeset//g; s/ nvidia//g;' /etc/mkinitcpio.conf
    sudo sed -i -E "s/^(MODULES=\()/\1${MODS} /" /etc/mkinitcpio.conf
    sudo mkinitcpio -P

    # Blacklist nouveau
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf >/dev/null

    # Dedicated GPU - nvidia handles display
    sudo mkdir -p /etc/X11/xorg.conf.d
    cat <<'EOF' | sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf >/dev/null
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "TripleBuffer" "on"
EndSection
EOF

    # Enable suspend/hibernate support
    sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

    echo "NVIDIA done. Reboot required."
}

install_bluetooth() {
    $PKG bluez bluez-utils bluetui
    sudo systemctl enable --now bluetooth.service
    sudo sed -i 's/#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf 2>/dev/null || true
}

install_printer() {
    $PKG cups cups-pdf system-config-printer
    sudo systemctl enable --now cups.service
    sudo usermod -aG lp "$USER"
}

install_virtualcam() {
    HEADERS=$(detect_kernel_headers)

    $PKG "$HEADERS" v4l2loopback-dkms v4l-utils
    sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1 2>/dev/null || true
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    echo 'options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf >/dev/null
}

[ "${SOURCED:-}" = "1" ] && return 0 2>/dev/null || true

case "${1:-}" in
    nvidia) install_nvidia ;;
    bluetooth) install_bluetooth ;;
    printer) install_printer ;;
    virtualcam) install_virtualcam ;;
    all) install_nvidia; install_bluetooth; install_printer; install_virtualcam ;;
    check)
        case "${2:-all}" in
            nvidia) check_nvidia ;;
            bluetooth) check_bluetooth ;;
            printer) check_printer ;;
            virtualcam) check_virtualcam ;;
            all) check_all ;;
        esac ;;
    *) cat <<EOF
Usage: $0 <command> [device]
  nvidia                 Install NVIDIA drivers (dedicated GPU)
  bluetooth|printer|virtualcam  Install driver
  all                    Install all hardware drivers
  check [device]         Verify setup
EOF
    ;;
esac
