#!/bin/bash
echo "Removing earlier files"
rm -rfv cdrom/*

echo "Assembling..."
cd bootcat/ && make && cd ..
cd bootloader/ && make && cd ..
cd kernel/ && make && cd ..
cd pem1/ && make && cd ..
cd pem2/ && make && cd ..
cd pem3/ && make && cd ..

echo "Run demo..."
mkisofs -V "PEM1" -R -J -c bootcat -b bootloader -no-emul-boot -boot-load-size 4 -o cd.iso cdrom/
qemu-system-x86_64 -boot d -cdrom cd.iso -vga cirrus -m 2G

echo "Done."

### for flash usb media
### sudo dd bs=4M if=cd.iso of=/dev/sdg && sync