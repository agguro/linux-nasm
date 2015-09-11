files = kirk spock

%: %.asm common.inc
	make	$@

all:	
	make clean
	make kirk
	make spock

clean:
	rm -f $(files) *.lst *.o
debug:
	make clean
	nasm -felf64 -Fstabs -g -o kirk.o -l kirk.lst kirk.asm
	nasm -felf64 -Fstabs -g -o spock.o -l spock.lst spock.asm
	ld -g -melf_x86_64 kirk.o -o kirk
	ld -g -melf_x86_64 spock.o -o spock

kirk: kirk.asm common.inc
	nasm -felf64 -o kirk.o -l kirk.lst kirk.asm
	ld -s -m elf_x86_64 kirk.o -o kirk

spock: spock.asm common.inc
	nasm -felf64 -o spock.o -l spock.lst spock.asm
	ld -s -m elf_x86_64 spock.o -o spock

	@echo "FIRST RUN kirk THEN RUN spock"