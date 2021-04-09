NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = arguments

arguments_NASMFLAGS = -f elf64 -F dwarf -g
arguments_LDFLAGS = -m elf_x86_64 -g 
arguments_SOURCES = arguments.asm

.asm.o:
	$(NASM) $(arguments_NASMFLAGS) $< -o $@
	
arguments$(EXEEXT): $(bin_PROGRAMS).o
	ld $(arguments_LDFLAGS) $(arguments_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(arguments_OBJS) $(bin_PROGRAMS)$(EXEEXT)
