# Install script

This script's purpose is to set up a new system while minimising the
efort. It's not neat and tidy - I only use it once in a while. It's
developed for my choice of distro - Linux Mint and my setup of
personal machine - it needs to run games and neovim alike. There is
no guarantee that it will work or even suit YOU. Now that you've been
warned - use it, take inspiration and let mee know if you have any
feedback.

## After installation

### Review notes

`install_me.sh` has some notes on recommended steps, take a look.

### Backup setup

Below is a manual for `crytsetup`. This is a distillation of nixCraft's
[article](https://www.cyberciti.biz/hardware/cryptsetup-add-enable-luks-disk-encryption-keyfile-linux/)
```bash
KEYFILE=/etc/backup_keyfile
DEVICE=/dev/sdb
DEV_NAME="backup"
# keyfile creation is in install_me.sh

# Prepare volume (All data will be lost!)
shred -v --iterations=1 $DEVICE
cryptsetup luksFormat $DEVICE
cryptsetup luksAddKey $DEVICE $KEYFILE
cryptsetup luksDump $DEVICE # verify

mkfs.ext4 /dev/mapper/$DEV_NAME
```

Add following to `/etc/crypttab`:
```
backup /dev/sdb /etc/backup_keyfile luks
```

Add following to `/etc/fstab`:
```
/dev/mapper/backup /backup ext4 defaults 1 2
```

Backup itself will be added later :)

