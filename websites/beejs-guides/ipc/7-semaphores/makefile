PROGRAMS = semdemo semrm

all: $(PROGRAMS)

% : %.asm
	nasm -felf64 -o $@.o -l $@.lst $@.asm
	ld -s -m elf_x86_64 $@.o -o $@
	
semdemo: semdemo.asm
semrm: semrm.asm

clean:
	rm -f $(PROGRAMS) *.lst *.o
