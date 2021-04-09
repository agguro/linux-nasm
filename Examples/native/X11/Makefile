BIN=x11info

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 --dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS= -lc -lX11

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(BIN) $(BIN).o

%: %.asm
	$(NASM) $(NASMOPTS) -o $@.o $<
	$(LD) $(LDOPS) -o $@ $@.o $(LIBS)
	rm -f $@.o
