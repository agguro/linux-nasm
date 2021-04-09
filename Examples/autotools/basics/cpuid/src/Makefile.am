NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = cpuid

cpuid_NASMFLAGS = -f elf64 -F dwarf -g
cpuid_LDFLAGS = -m elf_x86_64 -g 
cpuid_SOURCES = cpuid.asm

.asm.o:
	$(NASM) $(cpuid_NASMFLAGS) $< -o $@
	
cpuid$(EXEEXT): $(bin_PROGRAMS).o
	ld $(cpuid_LDFLAGS) $(cpuid_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(cpuid_OBJS) $(bin_PROGRAMS)$(EXEEXT)
