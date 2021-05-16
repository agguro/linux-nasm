TARGETS=cgiroot cookies downloaddata downloadfile jsonobject parsejsonobject postrequest querystring webvars

ASM=/usr/bin/nasm
LD=/usr/bin/ld
ASMOPTS=-felf64
LDOPTS=-m elf_x86_64

.PHONY: all clean pristine

all: $(TARGETS)

clean:
	rm -f $(TARGETS) *.o

pristine: clean

%: %.asm
	$(ASM) $(ASMOPTS) -o $@.o $<
	$(LD) -o $@ $(LDOPTS) $@.o $(LIBS)
