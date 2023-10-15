NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = entry
entry_NASMFLAGS = @PACKAGE_NASMFLAGS@
entry_LDFLAGS = @PACKAGE_LDFLAGS@
entry_LIBS = @PACKAGE_LIBS@
entry_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(entry_NASMFLAGS) $< -o $@
	
entry$(EXEEXT): $(bin_PROGRAMS).o
	ld $(entry_LDFLAGS) $(entry_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(entry_OBJS) $(bin_PROGRAMS)$(EXEEXT)
