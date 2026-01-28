#!/bin/sh
# Hardware drivers
# shellcheck disable=SC2015  # A && B || C pattern is safe here (ok/fail never fail)

set -e

PKG="paru -S --needed --noconfirm"
command -v paru >/dev/null || PKG="sudo pacman -S --needed --noconfirm"

ok() { printf "\033[32m✓\033[0m %s\n" "$1"; }
fail() { printf "\033[31m✗\033[0m %s\n" "$1"; }

check_nvidia() {
    lspci | grep -qi nvidia || { echo "No NVIDIA GPU"; return 0; }

    # Check envycontrol mode first
    if command -v envycontrol >/dev/null; then
        mode=$(envycontrol --query 2>/dev/null || echo "unknown")
        echo "GPU mode: $mode"
        [ "$mode" = "integrated" ] && { ok "GPU disabled (maximum battery)"; echo "Use 'dot hardware nvidia' to enable"; return 0; }
    fi

    err=0

    # Core driver checks
    lsmod | grep -q "^nvidia " && ok "nvidia module loaded" || { fail "nvidia module not loaded"; err=1; }
    lsmod | grep -q "^nvidia_drm " && ok "nvidia_drm module loaded" || { fail "nvidia_drm not loaded"; err=1; }
    [ -f /etc/modprobe.d/nvidia.conf ] && ok "modprobe config exists" || { fail "/etc/modprobe.d/nvidia.conf missing"; err=1; }
    [ -f /etc/modprobe.d/blacklist-nouveau.conf ] && ok "nouveau blacklisted" || { fail "nouveau not blacklisted"; err=1; }
    grep -q "nvidia" /etc/mkinitcpio.conf && ok "nvidia in initramfs" || { fail "nvidia not in initramfs"; err=1; }
    command -v nvidia-smi >/dev/null && nvidia-smi >/dev/null 2>&1 && ok "nvidia-smi working" || { fail "nvidia-smi failed"; err=1; }

    # Hybrid-specific checks
    if is_hybrid_gpu; then
        echo "--- Hybrid GPU (PRIME) ---"
        [ ! -f /etc/X11/xorg.conf.d/20-nvidia.conf ] && ok "no xorg nvidia config (correct for hybrid)" || { fail "xorg nvidia config exists (remove it)"; err=1; }
        [ -f /etc/udev/rules.d/80-nvidia-pm.rules ] && ok "RTD3 power management rules" || { fail "RTD3 udev rules missing"; err=1; }
        [ -f /etc/modprobe.d/nvidia-pm.conf ] && ok "dynamic power management config" || { fail "nvidia-pm.conf missing"; err=1; }
        systemctl is-enabled --quiet nvidia-persistenced && ok "nvidia-persistenced enabled" || { fail "nvidia-persistenced not enabled"; err=1; }
        command -v prime-run >/dev/null && ok "prime-run available" || { fail "prime-run missing (install nvidia-prime)"; err=1; }

        # Check GPU power state
        gpu_state=$(cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status 2>/dev/null)
        [ "$gpu_state" = "suspended" ] && ok "GPU powered off (RTD3 working)" || echo "  GPU state: $gpu_state (active or not idle)"
    fi

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
    fprintd-list "$USER" 2>/dev/null | grep -q "right-index-finger\|left-index-finger" && ok "fingerprint enrolled" || { fail "no fingerprint enrolled (run: fprintd-enroll)"; err=1; }
    [ -f /usr/local/bin/lid-check.sh ] && ok "lid-check.sh installed" || { fail "lid-check.sh not installed"; err=1; }
    [ -f /etc/pam.d/polkit-1 ] && grep -q "pam_fprintd.so" /etc/pam.d/polkit-1 && ok "polkit-1 has fprintd" || { fail "polkit-1 not configured"; err=1; }
    # Verify fingerprint is NOT in sudo or system-auth (security check)
    ! grep -q "pam_fprintd.so" /etc/pam.d/sudo 2>/dev/null && ok "sudo does NOT have fprintd (correct)" || { fail "SECURITY: sudo has fprintd (remove it!)"; err=1; }
    ! grep -q "pam_fprintd.so" /etc/pam.d/system-auth 2>/dev/null && ok "system-auth does NOT have fprintd (correct)" || { fail "SECURITY: system-auth has fprintd (remove it!)"; err=1; }
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

    # Install envycontrol for GPU switching
    command -v envycontrol >/dev/null || $PKG envycontrol

    # Detect GPU generation for driver selection
    if lspci | grep -i nvidia | grep -qE "RTX [2-9][0-9]|GTX 16"; then
        DRIVER="nvidia-open"
    else
        DRIVER="nvidia"
    fi

    HEADERS="linux-headers"
    pacman -Q linux-zen >/dev/null 2>&1 && HEADERS="linux-zen-headers"
    pacman -Q linux-lts >/dev/null 2>&1 && HEADERS="linux-lts-headers"

    # Enable multilib for 32-bit libs
    grep -q "^\[multilib\]" /etc/pacman.conf || {
        sudo sed -i '/^#\s*\[multilib\]/,/^#\s*Include/ s/^#\s*//' /etc/pacman.conf
        sudo pacman -Syu --noconfirm
    }

    $PKG $HEADERS $DRIVER nvidia-utils nvidia-settings lib32-nvidia-utils libva-nvidia-driver nvidia-prime || {
        echo "Retrying NVIDIA install..."
        sudo pacman -Syu --noconfirm
        $PKG $HEADERS $DRIVER nvidia-utils nvidia-settings lib32-nvidia-utils libva-nvidia-driver nvidia-prime
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

    # Hybrid GPU (PRIME render offload) setup
    if is_hybrid_gpu; then
        echo "Hybrid GPU detected - configuring PRIME render offload"

        # Remove any nvidia xorg config (iGPU handles display)
        [ -f /etc/X11/xorg.conf.d/20-nvidia.conf ] && sudo rm /etc/X11/xorg.conf.d/20-nvidia.conf

        # RTD3 power management (allows GPU to power off when idle)
        cat <<'EOF' | sudo tee /etc/udev/rules.d/80-nvidia-pm.rules >/dev/null
# Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"

# Enable runtime PM for NVIDIA VGA/3D controller devices on adding device
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
EOF

        # Dynamic power management (Turing+)
        cat <<'EOF' | sudo tee /etc/modprobe.d/nvidia-pm.conf >/dev/null
options nvidia NVreg_DynamicPowerManagement=0x02
EOF

        # Enable nvidia-persistenced to keep device state
        sudo systemctl enable nvidia-persistenced.service

        echo "PRIME offload configured. Use 'prime-run <app>' for GPU rendering."
    else
        # Dedicated GPU - nvidia handles display
        sudo mkdir -p /etc/X11/xorg.conf.d
        cat <<'EOF' | sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf >/dev/null
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "TripleBuffer" "on"
EndSection
EOF
    fi

    # Enable suspend/hibernate support
    sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

    # Switch to hybrid mode (GPU available via prime-run)
    echo "Enabling NVIDIA GPU (hybrid mode)..."
    sudo envycontrol -s hybrid --no-confirm

    echo "NVIDIA done. Reboot required."
}

disable_nvidia() {
    lspci | grep -qi nvidia || { echo "No NVIDIA GPU"; return 0; }
    command -v envycontrol >/dev/null || $PKG envycontrol

    echo "Disabling NVIDIA GPU (integrated mode)..."
    sudo envycontrol -s integrated --no-confirm
    echo "GPU disabled. Reboot required for maximum battery life."
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

    # Install lid-check script (skips fingerprint when lid closed/docked)
    DOTFILES="${DOTFILES:-$(cd "$(dirname "$0")/.." && pwd)}"
    sudo install -m755 "$DOTFILES/scripts/.local/bin/lid-check.sh" /usr/local/bin/lid-check.sh

    # Configure polkit-1 for fingerprint (1Password uses polkit for system auth)
    # NOTE: We ONLY configure polkit-1, NOT sudo/login/system-auth
    sudo tee /etc/pam.d/polkit-1 >/dev/null <<'EOF'
# Fingerprint for polkit (1Password) - skips if lid closed
auth    [success=ok default=1]  pam_exec.so quiet /usr/local/bin/lid-check.sh
auth    sufficient              pam_fprintd.so
auth    include                 system-auth
account include                 system-auth
password include                system-auth
session include                 system-auth
EOF

    echo ""
    echo "Fingerprint configured for 1Password only."
    echo "Next steps:"
    echo "  1. Enroll fingerprint: fprintd-enroll"
    echo "  2. Enable in 1Password: Settings > Security > 'Unlock using system authentication'"
}

install_virtualcam() {
    HEADERS="linux-headers"
    pacman -Q linux-zen >/dev/null 2>&1 && HEADERS="linux-zen-headers"
    pacman -Q linux-lts >/dev/null 2>&1 && HEADERS="linux-lts-headers"

    $PKG $HEADERS v4l2loopback-dkms v4l-utils
    sudo modprobe v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1 2>/dev/null || true
    echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    echo 'options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf >/dev/null
}

case "${1:-}" in
    nvidia)
        case "${2:-}" in
            disable) disable_nvidia ;;
            *) install_nvidia ;;
        esac ;;
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
  nvidia                 Install drivers and enable GPU (hybrid mode)
  nvidia disable         Disable GPU for maximum battery
  bluetooth|printer|fingerprint|virtualcam  Install driver
  all                    Install all hardware drivers
  check [device]         Verify setup
EOF
    ;;
esac
