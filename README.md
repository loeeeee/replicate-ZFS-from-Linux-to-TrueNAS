# Replicate ZFS from Linux to TrueNAS with Wake on LAN

This repo make it easy to do periodic replication of ZFS from Proxmox to a remote TrueNAS system.

- Easy Wake on LAN (WoL),
- Shutdown after finish,
- Same zettarepl as TrueNAS, and
- Easy configuration.

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

## How to use

### Prepare the machine

Firstly, one needs to make sure their account has permission to use command `zfs`. Typically, `root` user has such privilege, but a [guide](https://vaarlion.com/blog/zfs-replication-from-truenas-to-linux/) on the Internet also showcased how to allow non-root user to have access to `zfs` command. In this guide, I would be using a non-sudo user, named `zfs_sync` for the backup task.

Then, one needs to have following components available.

- `git`
    - for cloning this repo and zettarepl
- `python3` and `pip`
    - zettarepl is a Python program
- crontab
    - the way we schedule the backup
- `ssh`
    - the way things communicate with each other
- `wakeonlan`
    - this does Wake on LAN

### Clone the repo

Go to the home directory of the user that one would like to use for replication, which in this case is `zfs_sync`. Clone the repo. 

```bash
su zfs_sync # Assume one starts as root user
cd ~
git clone https://github.com/loeeeee/replicate-ZFS-from-Linux-to-TrueNAS.git
```

### Install the dependency

The following commands create a Python virtual environment and install zettarepl from the source.

```bash
cd ~/replicate-ZFS-from-Linux-to-TrueNAS
./dep.sh
```

### Configure the `zettarepl`

One first need to duplicate the `example-replication.yaml`, which is used by zettarepl for snapshot and replication task.

```bash
cp example-replication.yaml replication-data.yaml
```

Regarding how to modifying the config file, one could find it inside the example replication config file.

### Configure the `main.sh`

One first need to duplicate the `example.env`, which is used by `main.sh` for WoL and shutdown over LAN (fancy name for SSH in and do a `shutdown -p now`).

```bash
cp example.env 1.env
```

Fill in the needed information.

### Configure the SSH

The idea here is that `zfs_sync` user can ssh into the backup server without password, so that the script could verify if the remote TrueNAS server is booted up or not. Note that if ssh into TrueNAS as `root` user, one need to change some settings at TrueNAS.

```bash
ssh-keygen
ssh-copy-id -i /home/zfs_sync/.ssh/id_rsa.pub root@example.com
```

### Test the WoL

It is advised to test the WoL in command line to make sure WoL actually works. Both machine needs to be in one LAN, meaning one can reach another without the evolvement of a [router](https://www.geeksforgeeks.org/difference-between-router-and-switch/). Also, one need to check if WoL is supported and enabled in their BIOS. 

```bash
wakeonlan 1c:1b:aa:bb:cc:dd
```

### Test the replication

```bash
./main.sh 1.env
```

### Setup Crontab

```bash
crontab -e
```
