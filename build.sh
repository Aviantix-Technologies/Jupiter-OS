wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.2.tar.xz
tar xf linux-6.11.2.tar.xz
cd linux-6.11.2
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage
mkdir ~/jupter
mv zImage ~/jupiter # IDFK TODO
cd ..
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tar xjf busybox-1.36.1.tar.bz2
cd busybox-1.36.1
echo "Build static binary (no shared libs) (NEW"
sleep 5
make -j$(nproc)
mkdir ~/jupiter/initramfs
make CONFIG_PREFIX=/home/$USER/jupiter/initramfs install
cd ~/jupiter/initramfs
touch init
echo "#!/bin/sh

/bin/sh" >> init
chmod +x init

# Browser
# cd ~/
# wget https://raw.githubusercontent.com/spartrekus/links2/master/links-1.03.tar.gz
# tar xzf links-1.03
# cd links-1.03
# ./configure
# make
# sudo make install
# find . -name 'links*' -type f
# mkdir -p ~/dfs-arm/usr/bin/links/
# mv links ~/dfs-arm/usr/bin/links/links
# cd ~/jupiter/usr/bin/links/
# chmod +x link
find . | cpio -o -H newc ../init.cpio
cd ..
dd if=/dev/zero of=boot.img bs=1M count=50
syslinux boot.img
mkdir syslinux
mount boot.img syslinux
cp zImage init.cpio syslinux
umount syslinux

# Build ISO
sudo apt-get install xorriso genisoimage
mkdir -p ~/iso/{boot,rootfs}
cp ~/jupiter/syslinux/zImage ~/iso/boot/
cp ~/jupiter/syslinux/init.cpio ~/iso/boot/
cp ~/jupiter/boot.img ~/iso/boot/

mkdir ~/mnt/boot
sudo mount -o loop boot.img ~/mnt/boot
cp ~/iso/boot/zImage ~/mnt/boot/
cp ~/iso/boot/initramfs.cpio ~/mnt/boot/
touch ~/mnt/boot/boot/syslinux.cfg
echo 'DEFAULT linux
LABEL Jupiter
    KERNEL zImage
    INITRD initramfs.cpio
    APPEND root=/dev/ram0' | sudo tee ~/mnt/boot/syslinux.cfg
sudo umount ~/mnt/boot

xorriso -as mkisofs \
    -r -V "Jupiter Linux" \
    -b boot.syslinux \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -o ~/jupiter.iso \
    ~/iso
