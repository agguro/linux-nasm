NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = dirinfo

dirinfo_NASMFLAGS = -f elf64 -F dwarf -g
dirinfo_LDFLAGS = -m elf_x86_64 -g 
dirinfo_SOURCES = dirinfo.asm

.asm.o:
	$(NASM) $(dirinfo_NASMFLAGS) $< -o $@
	
dirinfo$(EXEEXT): $(bin_PROGRAMS).o
	ld $(dirinfo_LDFLAGS) $(dirinfo_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(dirinfo_OBJS) $(bin_PROGRAMS)$(EXEEXT)
