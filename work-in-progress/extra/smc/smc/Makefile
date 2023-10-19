TARGETS=smc
ASM=/usr/bin/nasm
LD=/usr/bin/ld
ASMOPTS=-felf32
LDOPTS=-m elf_i386
LIBS= 

.PHONY: all clean pristine

all: $(TARGETS)

clean:
	rm -f $(TARGETS) *.o

pristine: clean

%: %.asm
	$(ASM) $(ASMOPTS) -o $@.o $<
	$(LD) -o $@ $(LDOPTS) $@.o $(LIBS)
