# Arch Linux

## Pre-installation

### Set the keyboard layout

To install with an AZERTY keyboard, it's a temporary fix:
```sh
loadkeys fr
```

### Connect to internet

Check that the network interface is recognize
```sh
ip link
```

#### Connect to the wifi

A helpful utility is provided to connect to a wifi network easily:
```sh
wifi-menu
```

### Update the clock

```sh
timedatectl set-ntp true
```

### Partition the disks

There is more layout examples on the [ArchWiki](https://wiki.archlinux.org/index.php/Partitioning#Example_layouts).
And more details about how to [choose between MBR and GPT](https://wiki.archlinux.org/index.php/Partitioning#Choosing_between_GPT_and_MBR).

#### UEFI

The usual organization looks like:

| Mount point | Partition | Partition type                                               | gdisk's code     | Recommended size |
|--------------|-----------|--------------------------------------------------------------|------------------|------------------|
| /boot/efi    | /dev/sdX1 | `C12A7328-F81F-11D2-BA4B-00A0C93EC93B` EFI system partition  | ef00             | At least 260 MiB |
| /            | /dev/sdX2 | `4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709` Linux x86-64 root (/) | 8304             | 23 GiB - 32 GiB  |
| /home        | /dev/sdX3 | `933AC7E1-2EB4-4F13-B844-0E14E2AEF915` Linux /home           | 8302             | Rest of the disk |
| [SWAP]       | /dev/sdX4 | `0657FD6D-A4AB-43C4-84E5-0933C84B4F4F` Linux SWAP            | 8200             | 2 GiB            |

Use either gdisk or cgdisk to have a visual interface.

### Format the partitions

The UEFI partition must be in FAT:
```sh
mkfs.fat -F32 /dev/sdX1
```

The root and home partitions are usually formated in `ext4`:
```sh
mkfs.ext4 /dev/sdX2
mkfs.ext4 /dev/sdX3
```

Prepare the swap partition:
```sh
mkswap /dev/sdX4
swapon /dev/sdX4
```

### Mount the file system

We need to mount our new file system in order to install Arch on it:
```sh
mount /dev/sdX2 /mnt
mkdir /mnt/boot /mnt/home
mount /dev/sdX1 /mnt/boot
mount /dev/sdX3 /mnt/home
```

### Generate an fstab file

```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

### Install essential packages

Install the essential packages to have a working system:
```sh
pacstrap /mnt base linux linux-firmware git
```

### Switching to the newly installed system

Until now we were not in our system, let's switch to it:
```sh
arch-chroot /mnt
```

### Use the installation scripts

Clone the repository:
```sh
git clone https://github.com/camilledejoye/arch-install
```

Install your base system and create your user with:
```
./arch-install/00-base.sh
```

Follow the instructions to reboot, login with your username & password.
Continue the installation with:
```sh
./arch-instal/20-bspwm.sh
```

To finalize the installation: reboot, register the SSH key into GitHub
and launch the last script:
```sh
./arch-install/90-finish.sh
```
