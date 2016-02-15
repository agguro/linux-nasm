PROGRAMS = nlz ntz parity pop

all: $(PROGRAMS)

% : %.asm
	nasm -felf64 -o $@.o -l $@.lst $@.asm
	ld -m elf_x86_64 $@.o -o $@

nlz	: nlz.asm		# number of leading zeros
ttz	: ntz.asm		# number of trailing zeros
parity	: parity.asm		# calculate parity bit
pop	: pop.asm		# counting one bits

clean:
	rm -f $(PROGRAMS) *.lst *.o
