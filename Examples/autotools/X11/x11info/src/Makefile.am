NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = x11info

x11info_NASMFLAGS = -f elf64 -F dwarf -g
x11info_LDFLAGS = -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2
x11info_LIBS = -lc `pkg-config --libs x11`
x11info_SOURCES = x11info.asm

.asm.o:
	$(NASM) $(x11info_NASMFLAGS) $< -o $@
	
x11info$(EXEEXT): $(bin_PROGRAMS).o
	ld $(x11info_LDFLAGS) $(x11info_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(x11info_OBJS) $(bin_PROGRAMS)$(EXEEXT)