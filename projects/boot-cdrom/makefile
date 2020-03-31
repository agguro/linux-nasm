FILES = bootcat bootload kernel

CDROMDIR    = cdrom/
ISOFILE     = cd.iso

all: $(FILES)
	mkisofs -V PEM -R -J -c bootcat.bin -b bootload.bin -no-emul-boot -boot-load-size 4 -o $(ISOFILE) $(CDROMDIR)
	qemu-system-x86_64 -boot d -cdrom cd.iso -vga cirrus -m 512

bootcat:
	cd bootcat/ && make && cd ..

bootload:
	cd bootloader/ && make && cd ..
	
kernel:
	cd kernel/ && make && cd ..