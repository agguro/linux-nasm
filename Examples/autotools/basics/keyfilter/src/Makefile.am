NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = keyfilter

keyfilter_NASMFLAGS = -f elf64 -F dwarf -g
keyfilter_LDFLAGS = -m elf_x86_64 -g 
keyfilter_SOURCES = keyfilter.asm

.asm.o:
	$(NASM) $(keyfilter_NASMFLAGS) $< -o $@
	
keyfilter$(EXEEXT): $(bin_PROGRAMS).o
	ld $(keyfilter_LDFLAGS) $(keyfilter_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(keyfilter_OBJS) $(bin_PROGRAMS)$(EXEEXT)
