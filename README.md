# Replicate ZFS from Linux to TrueNAS with Wake on LAN

**Work in Progress**

An automation script that does replication from OpenZFS in Linux to TrueNAS

## Overview

Replication in TrueNAS is not a one-command thing in ZFS, but a clever usage of snapshot mechanism. When a snapshot is taken in ZFS, the file system would not write to the part of disks that is already utilized, instead, new part of the disks would be used. Thus, old state of the disk would be kept untouched. In other words, a snapshot is always a marker that contains information of the delta between itself and the last marker. When a replication happens, ZFS backup server only needs to copy the snapshot from the main system, given that they have **the same last snapshot to base on**.

The same last snapshot is not easy to achieve when the remote server does not power on regularly, and the main server rotates its snapshot, meaning old ones gets deleted, which can be common in home server settings. Thus, this guide would like to address such inconvenience by providing an automated script that wake up and shutdown backup server and do backups regularly.

The script here is expected to run on Proxmox VE, a Debian based virtualization platform, where ZFS ia a popular choice for its storage backend.

The heavy lifting of the replication task is completed by [**zettarepl**](https://github.com/truenas/zettarepl/tree/master), which is also used in TrueNAS.

### Script: `main.sh`

- Wake up remote server
- Wait until server is booted
- Handled by zettarepl
    - Take a snapshot
    - Send the replication
- Shutdown the server

### Script: `dep.sh`

- Create Python virtual environment
- Install zettarepl

### Config Example: `example-replication.yaml`

YAML config is used by zettarepl only.

- Showcase a typical push replication

### Config Example: `example.env`

env config is used by the main bash script only.

- Showcase a typical push replication