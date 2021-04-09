NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = dealcards

dealcards_NASMFLAGS = -f elf64 -F dwarf -g
dealcards_LDFLAGS = -m elf_x86_64 -g 
dealcards_SOURCES = dealcards.asm

.asm.o:
	$(NASM) $(dealcards_NASMFLAGS) $< -o $@
	
dealcards$(EXEEXT): $(bin_PROGRAMS).o
	ld $(dealcards_LDFLAGS) $(dealcards_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(dealcards_OBJS) $(bin_PROGRAMS)$(EXEEXT)
