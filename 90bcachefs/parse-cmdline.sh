#!/bin/sh
# Dracut parse for bcachefs root arguments
# Extends upstream to handle root_subvol= and unlock methods

[ "$fstype" = "bcachefs" ] || return 0

root_subvol=$(getarg root_subvol=)
bcachefs_unlock_method=$(getarg bcachefs_unlock_method=)
rootok=1
