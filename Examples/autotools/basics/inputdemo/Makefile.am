NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = inputdemo

inputdemo_NASMFLAGS = -f elf64 -F dwarf -g
inputdemo_LDFLAGS = -m elf_x86_64 -g 
inputdemo_SOURCES = inputdemo.asm

.asm.o:
	$(NASM) $(inputdemo_NASMFLAGS) $< -o $@
	
inputdemo$(EXEEXT): $(bin_PROGRAMS).o
	ld $(inputdemo_LDFLAGS) $(inputdemo_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(inputdemo_OBJS) $(bin_PROGRAMS)$(EXEEXT)
