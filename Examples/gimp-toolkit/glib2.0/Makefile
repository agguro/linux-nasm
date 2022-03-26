BIN=hash list tree
NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS=-lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lglib-2.0

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(BIN)

%: %.asm
	$(NASM) $(NASMOPTS) -o $@.o $<
	$(LD) $(LDOPS) -o $@ $@.o $(LIBS)
	rm -f $@.o

strip: $(BIN)
	strip -s $(BIN)
