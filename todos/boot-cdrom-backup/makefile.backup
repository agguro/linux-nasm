.PHONY : clean
.PHONY : again
.PHONY : dump
.PHONY : run
.PHONY : images
.PHONY : tar
.PHONY : all

NAME=bootload
TARGET=bin
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
DUMP        = .dump

OBJS = $(NAME)$(O)

$(NAME).o : $(NAME).asm
	$(AS) -f $(TARGET) -o $(NAME) $(NAME)$(ASM) -l $(NAME)$(LST)
	cp bootload cdrom/boot/
	rm -rf cdrom/cd.iso
	cd cdrom/
	mkisofs -R -J -c boot/bootcat.bin -b boot/bootload -no-emul-boot -boot-load-size 4 -o cd.iso cdrom/
	qemu-system-x86_64 -boot d -cdrom cd.iso -vga cirrus -m 512
	cd ..
	