#!/bin/sh

# This script assembles the PEM1 bootloader and kernel, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)

# Only the root user can mount the floppy disk image as a virtual
# drive (loopback mounting), in order to copy across the files

# (If you need to blank the floppy image: 'mkdosfs disk_images/mikeos.flp')

username=`whoami`
group=`id -g -n $username`

if test "`whoami`" != "root" ; then
	echo "Hello "$username","
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'sudo ./build.sh' to run this script as root"
	exit
fi

echo "- deleting binary files"
rm *.bin
echo "- deleting listing files"
rm *.lst
if [ -e images ]
  then
  echo "removing directory images and contents"
  rm -rf images/
fi

if [ ! -e images ]
  then
  echo "create directory images"
  mkdir images
fi

if [ -e floppy ]
  then
  echo "removing directory floppy"
  rm -rf floppy/
fi  

if [ ! -e floppy ]
  then
  echo "create directory floppy"
  mkdir floppy
fi

if [ -e bootload.asm ]
  then
  echo "assembling bootloader"
  nasm -f bin -o bootload.bin bootload.asm -l bootload.lst || exit
  else
  echo "bootload.asm is missing"
  exit
fi

if [ -e kernel.asm ]
  then
  echo "assembling kernel"
  nasm -f bin -o kernel.bin kernel.asm -l kernel.lst || exit
  else
  echo "kernel.asm is missing"
  exit
fi

echo "create new blank virtual floppy"
mkdosfs -C images/pem1.flp 1440 || exit

echo "creating floppy image pem1.flp in directory images"
dd status=noxfer conv=notrunc if=bootload.bin of=images/pem1.flp || exit

echo "mounting pem1.flp to directory floppy"
mount -o loop -t vfat images/pem1.flp floppy || exit
sleep 1

echo "copying kernel to floppy"
cp kernel.bin floppy/ || exit

echo "copying source files to floppy/source"
mkdir floppy/source/
cp bootload.asm floppy/source/
cp kernel.asm floppy/source/
cp bootload.lst floppy/source/
cp kernel.lst floppy/source/
cp build.sh floppy/source/

echo "unmounting floppy"
# keep unmounting until done
while mountpoint -q floppy
do
    umount floppy/
done

echo "creating iso image"
mkisofs -b pem1.flp -hide pem1.flp -quiet -V 'AGGURO PEM1' -input-charset iso8859-1 -o images/pem1.iso images/ || exit

echo "booting iso in virtual machine"
qemu-system-i386 -cdrom images/pem1.iso -k nl-be -std-vga || exit

echo "deleting floppy directory"
rm -rf floppy/
exit