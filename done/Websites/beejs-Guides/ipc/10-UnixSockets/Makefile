BIN=echos echoc spair
NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g

.PRECIOUS: %.o

%: %.o
	$(LD) $(LDOPS) -o $@ $@.o

%.o: %.asm
	$(NASM) $(NASMOPTS) -o $@ $<

.PHONY: all clean

all: $(BIN)

clean:
	-rm -rf $(BIN) *.o gmon.out

