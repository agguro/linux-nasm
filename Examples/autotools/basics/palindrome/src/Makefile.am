NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = palindrome

palindrome_NASMFLAGS = -f elf64 -F dwarf -g
palindrome_LDFLAGS = -m elf_x86_64 -g 
palindrome_SOURCES = palindrome.asm

.asm.o:
	$(NASM) $(palindrome_NASMFLAGS) $< -o $@
	
palindrome$(EXEEXT): $(bin_PROGRAMS).o
	ld $(palindrome_LDFLAGS) $(palindrome_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(palindrome_OBJS) $(bin_PROGRAMS)$(EXEEXT)
