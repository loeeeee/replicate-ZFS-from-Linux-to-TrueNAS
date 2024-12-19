# Replicate ZFS from Linux to TrueNAS with Wake on LAN

**Work in Progress**

An automation script that does replication from OpenZFS in Linux to TrueNAS

## Overview

Replication in TrueNAS is not a one-command thing in ZFS, but a clever usage of snapshot mechanism. When a snapshot is taken in ZFS, the file system would not write to the part of disks that is already utilized, instead, new part of the disks would be used. Thus, old state of the disk would be kept untouched. In other words, a snapshot is always a marker that contains information of the delta between itself and the last marker. When a replication happens, ZFS backup server only needs to copy the snapshot from the main system, given that they have **the same last snapshot to base on**.

The same last snapshot is not easy to achieve when the remote server does not power on regularly, and the main server rotates its snapshot, meaning old ones gets deleted, which can be common in home server settings. Thus, this guide would like to address such inconvenience by providing an automated script that wake up and shutdown backup server and do backups regularly.

The script here is expected to run on Proxmox VE, a Debian based virtualization platform, where ZFS ia a popular choice for its storage backend.

### Script: `main.sh`

This script works in Linux server. It wakes up the server using WoL, a standard that gets ubiquitous support in all platform. Then, it will take the latest snapshot of the file system. Finally, it will wait until the backup server to fully boot up and starts sending the datasets.
