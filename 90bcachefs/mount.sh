#!/bin/sh
# Mount handler for bcachefs root volumes (dracut)

[ "$fstype" = "bcachefs" ] || return 0
dev="${root#block:}"

case "$dev" in
    /dev/disk/by-uuid/*) dev="UUID=${dev##*/}" ;;
esac

if [ -n "$root_subvol" ]; then
    mkdir /bcachefs_root
    bcachefs mount "$dev" /bcachefs_root
    real_root="/bcachefs_root$root_subvol"
    [ -d "$real_root" ] || die "root_subvol=$root_subvol does not exist"

    mount -o bind "$real_root" "/sysroot"
    mkdir -p "/sysroot/.bcachefs"
    mount -o bind "/bcachefs_root" "/sysroot/.bcachefs"
else
    bcachefs mount "$dev" "/sysroot"
fi


