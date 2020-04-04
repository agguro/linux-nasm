BIN=fork1 sigint sigusr pipe1 pipe2 pipe3 speak tick lockdemo kirk spock semdemo semrm shmdemo mmapdemo echoc echos spair forkdemo exeapp1 exeapp2 exeapp3 exeapp4 sigfpe threads  pipedemo1 pipedemo2 pipedemo3 pipedemo4 pipedemo5 pipedemo6 

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
