NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = cwd

cwd_NASMFLAGS = -f elf64 -F dwarf -g
cwd_LDFLAGS = -m elf_x86_64 -g 
cwd_SOURCES = cwd.asm

.asm.o:
	$(NASM) $(cwd_NASMFLAGS) $< -o $@
	
cwd$(EXEEXT): $(bin_PROGRAMS).o
	ld $(cwd_LDFLAGS) $(cwd_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(cwd_OBJS) $(bin_PROGRAMS)$(EXEEXT)
