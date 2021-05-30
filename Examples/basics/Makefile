BIN=arguments cpuid cwd dealcards dirinfo hello inputdemo keyfilter palindrome printenv readfile rotatebits uuid waitforkeypress waitforenterkeypress winsize

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g
OBJ = o
LST = lst

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(BIN) *.$(OBJ) *.$(LST)

%: %.asm
	$(NASM) $(NASMOPTS) -o $@.$(OBJ) -l $@.$(LST) $<
	$(LD) $(LDOPS) -o $@ $@.$(OBJ)
	
