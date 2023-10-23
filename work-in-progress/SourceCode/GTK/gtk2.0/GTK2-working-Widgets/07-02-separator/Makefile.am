NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = separator
separator_NASMFLAGS = @PACKAGE_NASMFLAGS@
separator_LDFLAGS = @PACKAGE_LDFLAGS@
separator_LIBS = @PACKAGE_LIBS@
separator_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(separator_NASMFLAGS) $< -o $@
	
separator$(EXEEXT): $(bin_PROGRAMS).o
	ld $(separator_LDFLAGS) $(separator_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(separator_OBJS) $(bin_PROGRAMS)$(EXEEXT)
