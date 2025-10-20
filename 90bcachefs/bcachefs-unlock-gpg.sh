#!/bin/sh
# /usr/sbin/bcachefs-unlock-gpg.sh:
# Decrypt password using GPG and unlock the volume
GPG_KEY="/etc/keys/bcachefs.gpg"
DEV="/dev/sdX"
echo "Unlocking $DEV..."
gpg --decrypt "$GPG_KEY" | bcachefs unlock "$DEV"
