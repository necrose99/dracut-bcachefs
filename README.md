This module allows mounting an encrypted bcachefs subvolume as `/`. The root of
the bcachefs filesystem is made available at `/.bcachefs`.

Not working with systemd (yet).

```
# kernel cmdline
rootfstype=bcachefs root=UUID=<external uuid> root_subvol=<root path>
```

Additional subvolumes can be mounted using fstab.
```
# /etc/fstab
/.bcachefs/<home subvol path>   /home   none  defaults,bind 0 0


```
Unlock Methods
Method	Description
TPM2	Use tpm2_unseal with a configured handle.
GPG	Use an encrypted key file (default: /etc/keys/bcachefs.gpg).
YubiKey	Retrieve OTP from configured OATH slot BCACHEFS.
Manual	Fallback prompt if no automated method succeeds.

The module tries each method in order until unlock succeeds.

Systemd Integration

The module now supports systemd units:

systemd-bcachefs-unlock@.service for unlocking devices during boot.

Example to enable root device unlock:

systemctl enable systemd-bcachefs-unlock@dev-sda2.service


Note: Systemd support requires udev and initqueue integration. Optional: 80-bcachefs.rules triggers the unlock after device detection.

OpenRC Integration

OpenRC users can enable /etc/init.d/bcachefs-unlock:

rc-update add bcachefs-unlock boot

Configuration Template

A declarative template /etc/bcachefs-tab can be used to specify devices, keys, and unlock methods:

# Format: UUID=<uuid> DEV=<device> KEY=<file|tpm2|yubikey> METHOD=<tpm2|gpg|yubikey|manual>
UUID=abcd-ef12-3456 DEV=/dev/sda2 KEY=/etc/keys/rootfs.gpg METHOD=gpg
UUID=1234-5678-abcd DEV=/dev/nvme0n1p3 KEY=tpm2:auto METHOD=tpm2


Copy /etc/bcachefs-tab.new to /etc/bcachefs-tab and edit accordingly.

Installation
Dracut Module
make install-dracut
dracut --force --add 90bcachefs

Systemd Unit
make install-systemd
systemctl daemon-reload
systemctl enable systemd-bcachefs-unlock@dev-sda2.service

OpenRC Script
make install-openrc
rc-update add bcachefs-unlock boot

Template
make install-tab
cp /etc/bcachefs-tab.new /etc/bcachefs-tab

Notes

The root of the bcachefs filesystem is always available at /.bcachefs for additional mounts.

Additional subvolumes must be mounted manually in /etc/fstab or via post-boot scripts.

Works with both encrypted root and data volumes.

Tested on both OpenRC and systemd setups with TPM2/GPG/YubiKey unlock support.