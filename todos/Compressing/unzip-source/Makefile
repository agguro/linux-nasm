BIN=zip unzip

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g

all: $(BIN)

$(BIN): $(BIN)-source/$(BIN).o
	$(LD) $(LDOPS) -o $(BIN) $(BIN)-source/$(BIN).o

$(BIN).o: $(BIN)/$(BIN).asm
	$(NASM) $(NASMOPTS) -o $(BIN)-source/$(BIN).o $(BIN)-source/$(BIN).asm

.PHONY: clean
clean:
	rm -f $(BIN)-source/$(BIN).o $(BIN)
