BIN=arguments cpuid cwd dealcards dirinfo hello inputdemo keyfilter palindrome printenv readfile rotatebits uuid waitforkeypress waitforenterkeypress winsize

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
