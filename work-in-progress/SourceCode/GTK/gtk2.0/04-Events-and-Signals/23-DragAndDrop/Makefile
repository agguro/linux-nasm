BIN=dragndrop

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf -g
LDOPS= --dynamic-linker /lib64/ld-linux-x86-64.so.2 -no-pie -melf_x86_64 -g
LIBS= -lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lgobject-2.0 -lgdk_pixbuf-2.0 -lglib-2.0

all: $(BIN)

$(BIN): $(BIN).o
	$(LD) $(LDOPS) -o $(BIN) $(BIN).o $(LIBS)

$(BIN).o: $(BIN).asm
	$(NASM) $(NASMOPTS) -o $(BIN).o $(BIN).asm

.PHONY: clean
clean:
	rm -f $(BIN).o $(BIN)
