NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = toolbar
toolbar_NASMFLAGS = @PACKAGE_NASMFLAGS@
toolbar_LDFLAGS = @PACKAGE_LDFLAGS@
toolbar_LIBS = @PACKAGE_LIBS@
toolbar_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(toolbar_NASMFLAGS) $< -o $@
	
toolbar$(EXEEXT): $(bin_PROGRAMS).o
	ld $(toolbar_LDFLAGS) $(toolbar_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(toolbar_OBJS) $(bin_PROGRAMS)$(EXEEXT)
