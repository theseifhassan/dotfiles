#!/bin/sh
# Hardware drivers

set -e

PKG="yay -S --needed --noconfirm"
command -v yay >/dev/null || PKG="sudo pacman -S --needed --noconfirm"

ok() { printf "\033[32m✓\033[0m %s\n" "$1"; }
fail() { printf "\033[31m✗\033[0m %s\n" "$1"; }

check_nvidia() {
    lspci | grep -qi nvidia || { echo "No NVIDIA GPU"; return 0; }
    err=0
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

check_fingerprint() {
    lsusb | grep -qi "fingerprint\|goodix\|synaptics\|elan" || { echo "No fingerprint reader"; return 0; }
    err=0
    pacman -Q fprintd >/dev/null 2>&1 && ok "fprintd installed" || { fail "fprintd not installed"; err=1; }
    fprintd-list "$USER" >/dev/null 2>&1 && ok "fingerprint enrolled" || { fail "no fingerprint enrolled"; err=1; }
    [ $err -eq 0 ] && echo "Fingerprint: all good" || echo "Fingerprint: issues found"
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
    check_fingerprint; echo
    check_virtualcam
}

is_hybrid_gpu() {
    # Check if both Intel/AMD iGPU and NVIDIA dGPU exist
    lspci | grep -qiE "VGA.*(Intel|AMD)" && lspci | grep -qi "NVIDIA"
}

install_nvidia() {
    lspci | grep -qi nvidia || { echo "No NVIDIA GPU"; return 0; }

    if lspci | grep -i nvidia | grep -qE "RTX [2-9][0-9]|GTX 16"; then
        DRIVER="nvidia-open"
    else
        DRIVER="nvidia"
    fi

    HEADERS="linux-headers"
    pacman -Q linux-zen &>/dev/null && HEADERS="linux-zen-headers"
    pacman -Q linux-lts &>/dev/null && HEADERS="linux-lts-headers"

    grep -q "^\[multilib\]" /etc/pacman.conf || {
        sudo sed -i '/^#\s*\[multilib\]/,/^#\s*Include/ s/^#\s*//' /etc/pacman.conf
        sudo pacman -Sy
    }

    $PKG $HEADERS $DRIVER nvidia-utils nvidia-settings lib32-nvidia-utils libva-nvidia-driver

    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
    echo "options nvidia preserve_video_memory_allocations=1" | sudo tee -a /etc/modprobe.d/nvidia.conf >/dev/null

    MODS="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
    sudo sed -i -E 's/ nvidia_drm//g; s/ nvidia_uvm//g; s/ nvidia_modeset//g; s/ nvidia//g;' /etc/mkinitcpio.conf
    sudo sed -i -E "s/^(MODULES=\()/\1${MODS} /" /etc/mkinitcpio.conf
    sudo mkinitcpio -P

    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf >/dev/null

    # Only create xorg nvidia config for dedicated GPU systems (not hybrid)
    if is_hybrid_gpu; then
        echo "Hybrid GPU detected - skipping xorg nvidia config (iGPU handles display)"
        # Remove existing config if present
        [ -f /etc/X11/xorg.conf.d/20-nvidia.conf ] && sudo rm /etc/X11/xorg.conf.d/20-nvidia.conf
    else
        sudo mkdir -p /etc/X11/xorg.conf.d
        sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf >/dev/null <<'EOF'
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "TripleBuffer" "on"
EndSection
EOF
    fi

    sudo mkdir -p /etc/environment.d
    echo -e "LIBVA_DRIVER_NAME=nvidia\nNVD_BACKEND=direct" | sudo tee /etc/environment.d/10-nvidia.conf >/dev/null

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

install_fingerprint() {
    lsusb | grep -qi "fingerprint\|goodix\|synaptics\|elan" || { echo "No fingerprint reader"; return 0; }
    $PKG fprintd
    echo "Enroll: fprintd-enroll"
}

install_virtualcam() {
    HEADERS="linux-headers"
    pacman -Q linux-zen &>/dev/null && HEADERS="linux-zen-headers"
    pacman -Q linux-lts &>/dev/null && HEADERS="linux-lts-headers"

    $PKG $HEADERS v4l2loopback-dkms v4l-utils
    sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1 2>/dev/null || true
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    echo 'options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf >/dev/null
}

case "${1:-}" in
    nvidia) install_nvidia ;;
    bluetooth) install_bluetooth ;;
    printer) install_printer ;;
    fingerprint) install_fingerprint ;;
    virtualcam) install_virtualcam ;;
    all) install_nvidia; install_bluetooth; install_printer; install_fingerprint; install_virtualcam ;;
    check)
        case "${2:-all}" in
            nvidia) check_nvidia ;;
            bluetooth) check_bluetooth ;;
            printer) check_printer ;;
            fingerprint) check_fingerprint ;;
            virtualcam) check_virtualcam ;;
            all) check_all ;;
        esac ;;
    *) cat <<EOF
Usage: $0 <command> [device]
  nvidia|bluetooth|printer|fingerprint|virtualcam  Install driver
  all                                               Install all
  check [device]                                    Verify setup
EOF
    ;;
esac
