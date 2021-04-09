NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = notify

notify_NASMFLAGS = -f elf64 -F dwarf -g
notify_LDFLAGS = -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2
notify_LIBS = -lnotify -lc
notify_SOURCES = notify.asm

.asm.o:
	$(NASM) $(notify_NASMFLAGS) $< -o $@
	
notify$(EXEEXT): $(bin_PROGRAMS).o
	ld $(notify_LDFLAGS) $(notify_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(notify_OBJS) $(bin_PROGRAMS)$(EXEEXT)