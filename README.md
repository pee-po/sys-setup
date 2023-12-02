# Install script

This script's purpose is to set up a new system while minimising the
efort. It's not neat and tidy - I only use it once in a while. It's
developed for my choice of distro - Linux Mint and my setup of
personal machine - it needs to run games and neovim alike. There is
no guarantee that it will work or even suit YOU. Now that you've been
warned - use it, take inspiration and let mee know if you have any
feedback.

## Before installation

## Installation

```bash
wget -q -O - \
https://raw.githubusercontent.com/pee-po/sys-setup/master/install_me.sh \
sudo bash
```

## After installation

### Review notes

`install_me.sh` has some notes on recommended steps, take a look.

### Backup setup

Below is a manual for `crytsetup`. This is a distillation of nixCraft's
[article](https://www.cyberciti.biz/hardware/cryptsetup-add-enable-luks-disk-encryption-keyfile-linux/)
if you need more than simple mount - refer to the article. You can
generally do this with other stuff - additional drives or even parts of
[FHS](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)
but beware of what dirs have to be mounted at what point. I wanted
to mount `/usr` from another SDD - turns out [it's an issue](https://wiki.freedesktop.org/www/Software/systemd/separate-usr-is-broken/).
So I mount `/usr/local` and that's where I store "heavy" stuff like games.
In hindsight - maybe `/opt` is a better place for that.

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

# Open and format
cryptsetup luksOpen $DEVICE $DEV_NAME --key-file $KEYFILE
mkfs.ext4 /dev/mapper/$DEV_NAME
```

Substitute bracketed names for values of variables and add following
to `/etc/crypttab`:
```
<DEV_NAME> <DEVICE> <KEYFILE> luks
```

Substitute bracketed names for values of variables and add following
to `/etc/fstab`:
```
/dev/mapper/<DEV_NAME> <MOUNT_POINT> ext4 defaults 1 2
```

Or you can paste following into bash and copy into propper files:
```
echo
echo to /etc/crypttab :
echo $DEV_NAME $DEVICE $KEYFILE luks
echo to /etc/crypttab :
echo /dev/mapper/$DEV_NAME /$DEV_NAME ext4 defaults 1 2
```

Backup itself will be added later :)

