.PHONY: all clean

all:fibrecursive fibiterative

clean:
	rm -rf fibrecursive fibrecursive.o fibiterative fibiterative.o

fibrecursive: fibrecursive.o
	ld -melf_x86_64 -o fibrecursive fibrecursive.o

fibrecursive.o: fibrecursive.asm
	nasm -felf64 -Fdwarf -o fibrecursive.o fibrecursive.asm

fibiterative: fibiterative.o
	ld -melf_x86_64 -o fibiterative fibiterative.o

fibiterative.o: fibiterative.asm
	nasm -felf64 -Fdwarf -o fibiterative.o fibiterative.asm
