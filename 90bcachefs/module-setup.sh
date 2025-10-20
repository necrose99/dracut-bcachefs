#!/bin/sh
# Dracut module setup for bcachefs
# Enhanced for TPM2 / GPG / YubiKey unlock support
# Compatible with upstream breavyn/dracut-bcachefs and kode54/dracut-hook-bcachefs

check() {
    require_binaries bcachefs || return 1
    return 0
}

depends() {
    # No mandatory deps, but dracut may include udev and crypt hooks if available
    echo "udev"
    return 0
}

install() {
    # Core binaries required for root unlock and mount
    inst_multiple bcachefs keyctl modprobe

    # Optional unlock toolchain (install only if present)
    inst_any tpm2_unseal gpg ykman || true

    # Optional key storage
    [ -f /etc/keys/bcachefs.gpg ] && inst /etc/keys/bcachefs.gpg /etc/keys/bcachefs.gpg

    # Install hook scripts
    inst_hook cmdline 90 "$moddir/parse-cmdline.sh"
    inst_hook pre-mount 90 "$moddir/unlock.sh"
    inst_hook mount 90 "$moddir/mount.sh"

    # Optional udev rule for async device handling (systemd-based initramfs)
    if [ -f "$moddir/80-bcachefs.rules" ]; then
        inst_rules "$moddir/80-bcachefs.rules"
        inst_simple "$moddir/bcachefs_finished" "/sbin/bcachefs_finished"
    fi

    # Logging for verification
    inst_simple /usr/bin/echo /usr/bin/echo || true
}
