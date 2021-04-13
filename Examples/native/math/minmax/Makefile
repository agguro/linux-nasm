BIN=minmax

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g

.PHONY: all clean

all: minmax
	
clean:
	rm -rf minmax minmax.o

minmax.o: minmax.asm
	nasm -felf64 -Fdwarf -o minmax.o minmax.asm

minmax: minmax.o
	ld -melf_x86_64 -o minmax minmax.o

