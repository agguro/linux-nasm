#!/bin/bash
echo "Removing earlier files"
rm -rfv cdrom/*
rm -fv bootcat/bootcat
rm -fv bootloader/bootloader
rm -fv kernel/kernel.bin
rm -fv pem1/pem1.bin
rm -fv pem2/pem2.bin
rm -fv pem3/pem3.bin

echo "Assembling..."
cd bootcat/ && make && cd ..
cd bootloader/ && make && cd ..
cd kernel/ && make && cd ..
cd pem1/ && make && cd ..
cd pem2/ && make && cd ..
cd pem3/ && make && cd ..

echo "Copying..."
cp -v bootcat/bootcat cdrom/
cp -v bootloader/bootloader cdrom/
cp -v kernel/kernel.bin cdrom/
cp -v pem1/pem1.bin cdrom/
cp -v pem2/pem2.bin cdrom/
cp -v pem3/pem3.bin cdrom/

echo "Run demo..."
mkisofs -V "PEM1" -R -J -c bootcat -b bootloader -no-emul-boot -boot-load-size 4 -o cd.iso cdrom/
qemu-system-x86_64 -boot d -cdrom cd.iso -vga cirrus -m 512

echo "Done."

### for flash usb media
### sudo dd bs=4M if=cd.iso of=/dev/sdg && sync