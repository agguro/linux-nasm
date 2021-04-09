NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = hello

hello_NASMFLAGS = -f elf64 -F dwarf -g
hello_LDFLAGS = -m elf_x86_64 -g 
hello_SOURCES = hello.asm

.asm.o:
	$(NASM) $(hello_NASMFLAGS) $< -o $@
	
hello$(EXEEXT): $(bin_PROGRAMS).o
	ld $(hello_LDFLAGS) $(hello_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(hello_OBJS) $(bin_PROGRAMS)$(EXEEXT)
