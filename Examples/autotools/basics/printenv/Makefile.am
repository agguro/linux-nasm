NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = printenv

printenv_NASMFLAGS = -f elf64 -F dwarf -g
printenv_LDFLAGS = -m elf_x86_64 -g 
printenv_SOURCES = printenv.asm

.asm.o:
	$(NASM) $(printenv_NASMFLAGS) $< -o $@
	
printenv$(EXEEXT): $(bin_PROGRAMS).o
	ld $(printenv_LDFLAGS) $(printenv_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(printenv_OBJS) $(bin_PROGRAMS)$(EXEEXT)
