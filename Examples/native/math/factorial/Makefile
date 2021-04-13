.PHONY: all clean

all: $(BIN)
	$(MAKE) facrecursive

clean:
	rm -rf facrecursive facrecursive.o

facrecursive: facrecursive.o
	ld -melf_x86_64 -o facrecursive facrecursive.o

facrecursive.o: facrecursive.asm
	nasm -felf64 -Fdwarf -o facrecursive.o facrecursive.asm
