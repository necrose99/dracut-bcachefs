#!/bin/sh
# Enhanced unlock for bcachefs with TPM2/GPG/YubiKey integration

[ "$fstype" = "bcachefs" ] || return 0
dev="${root#block:}"

modprobe bcachefs 2>/dev/null || true

unlock_device() {
    echo "$1" | bcachefs unlock "$dev" >/dev/null 2>&1
}

# 1. TPM2 key attempt
if command -v tpm2_unseal >/dev/null 2>&1; then
    TPM_HANDLE=${TPM_HANDLE:-0x81010001}
    if KEY=$(tpm2_unseal -c "$TPM_HANDLE" 2>/dev/null); then
        unlock_device "$KEY" && info "$dev unlocked via TPM2" && return 0
    fi
fi

# 2. GPG fallback
if [ -f /etc/keys/bcachefs.gpg ] && command -v gpg >/dev/null 2>&1; then
    if KEY=$(gpg --decrypt /etc/keys/bcachefs.gpg 2>/dev/null); then
        unlock_device "$KEY" && info "$dev unlocked via GPG" && return 0
    fi
fi

# 3. YubiKey OATH fallback
if command -v ykman >/dev/null 2>&1; then
    if KEY=$(ykman oath code "BCACHEFS" 2>/dev/null | awk '{print $NF}'); then
        unlock_device "$KEY" && info "$dev unlocked via YubiKey" && return 0
    fi
fi

# 4. Manual unlock (upstream-compatible)
info "Please unlock $dev:"
for _ in 1 2 3; do
    bcachefs unlock "$dev" && \
      keyctl link @u @s && \
      info "$dev successfully unlocked" && \
      return 0
done

die "maximum number of tries exceeded for $dev"
