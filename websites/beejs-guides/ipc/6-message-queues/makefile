PROGRAMS = kirk spock

all: $(PROGRAMS)

% : %.asm common.inc
	nasm -felf64 -o $@.o -l $@.lst $@.asm
	ld -s -m elf_x86_64 $@.o -o $@
	@echo "FIRST RUN kirk THEN RUN spock"
	
kirk: kirk.asm
spock: spock.asm

clean:
	rm -f $(PROGRAMS) *.lst *.o
