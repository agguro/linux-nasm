PROGRAMS = tick speak

all: $(PROGRAMS)

%: %.asm section.bss.inc
	nasm -felf64 -o $@.o -l $@.lst $@.asm
	ld -s -m elf_x86_64 $@.o -o $@
	
tick: tick.asm
speak: speak.asm

clean:
	rm -f $(PROGRAMS) *.lst *.o fifo-buffer
