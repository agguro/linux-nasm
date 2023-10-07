BIN=definitions

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g
DYN=--dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS=-lssl -lcrypto     #install sudo apt install libssl-dev

.PHONY: all clean

all: $(BIN)

clean:
	rm -f $(BIN)/$(BIN).o
	rm -f bin/*

definitions/definitions.o: definitions/definitions.asm
	$(NASM) $(NASMOPTS) definitions/definitions.asm -o definitions/definitions.o

definitions: definitions/definitions.o
	$(LD) $(DYN) $(LDOPS) -o bin/definitions definitions/definitions.o $(LIBS)
