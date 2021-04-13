BIN=facrecursive fibiterative fibrecursive minmax

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g

.PHONY: all clean

all: $(BIN)
	$(MAKE) $(BIN)

clean:
	rm -rf $(BIN)

facrecursive: facrecursive.o
	ld -melf_x86_64 -o facrecursive facrecursive.o

fibrecursive: fibrecursive.o
	ld -melf_x86_64 -o fibrecursive fibrecursive.o

fibiterative: fibiterative.o
	ld -melf_x86_64 -o fibiterative fibiterative.o

minmax: minmax.o
	ld -melf_x86_64 -o minmax minmax.o

facrecursive.o: facrecursive.asm
	nasm -felf64 -Fdwarf -o facrecursive.o factorial/facrecursive.asm

fibrecursive.o: fibrecursive.asm
	nasm -felf64 -Fdwarf -o fibrecursive.o fibonacci/fibrecursive.asm

fibiterative.o: fibiterative.asm
	nasm -felf64 -Fdwarf -o fibiterative.o fibonacci/fibiterative.asm

minmax.o: minmax.asm
	nasm -felf64 -Fdwarf -o minmax.o minmax/minmax.asm