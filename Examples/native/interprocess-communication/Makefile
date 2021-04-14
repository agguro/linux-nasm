BIN= exeapp1 exeapp2 exeapp3 exeapp4 extxterm forkdemo pipedemo1 pipedemo2 pipedemo3 pipedemo4 pipedemo5 pipedemo6 forkdemo sigfpe threads

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(BIN)

%: %.asm
	$(NASM) $(NASMOPTS) -o $@.o $<
	$(LD) $(LDOPS) -o $@ $@.o
	rm -f $@.o
