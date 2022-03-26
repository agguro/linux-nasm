BIN=extxterm 

#hello hello2 create-pipes redirect-pipes

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g

.PHONY: all clean pristine

all: $(BIN)

clean:
	rm -rf $(BIN)

pristine: clean

%: %.asm
	$(NASM) $(NASMOPTS) -o $@.o $<
	$(LD) $(LDOPS) -o $@ $@.o
	rm -f $@.o
