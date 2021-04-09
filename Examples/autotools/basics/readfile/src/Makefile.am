NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = readfile

readfile_NASMFLAGS = -f elf64 -F dwarf -g
readfile_LDFLAGS = -m elf_x86_64 -g 
readfile_SOURCES = readfile.asm

.asm.o:
	$(NASM) $(readfile_NASMFLAGS) $< -o $@
	
readfile$(EXEEXT): $(bin_PROGRAMS).o
	ld $(readfile_LDFLAGS) $(readfile_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(readfile_OBJS) $(bin_PROGRAMS)$(EXEEXT)
