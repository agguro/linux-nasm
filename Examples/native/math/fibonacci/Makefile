NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g

.PHONY: all clean

all:
	$(MAKE) fibrecursive
	$(MAKE) fibiterative

clean:
	rm -rf *.o fibiterative fibrecursive

fibrecursive.o: fibrecursive.asm
	nasm -felf64 -Fdwarf -o fibrecursive.o fibrecursive.asm

fibiterative.o: fibiterative.asm
	nasm -felf64 -Fdwarf -o fibiterative.o fibiterative.asm
	
fibrecursive: fibrecursive.o
	ld -melf_x86_64 -o fibrecursive fibrecursive.o

fibiterative: fibiterative.o
	ld -melf_x86_64 -o fibiterative fibiterative.o

