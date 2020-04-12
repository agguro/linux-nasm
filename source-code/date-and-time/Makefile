BIN=daysinmonth leapyear trimester quadrimester semester shiftedmonth sleep
NASM=/usr/bin/nasm
NASMOPTS=-felf64
NASMDBG=-Fdwarf

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(BIN).o $(BIN).dev.o $(BIN)

%: %.asm %.c
	$(NASM) $(NASMOPTS) -o $@.o $<
	$(NASM) $(NASMOPTS) $(NASMDBG) -o $@.dev.o $<
	$(CC) -o $@ $@.c $@.o
