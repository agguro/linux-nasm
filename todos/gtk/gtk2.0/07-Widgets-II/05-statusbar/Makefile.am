NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = statusbar
statusbar_NASMFLAGS = @PACKAGE_NASMFLAGS@
statusbar_LDFLAGS = @PACKAGE_LDFLAGS@
statusbar_LIBS = @PACKAGE_LIBS@
statusbar_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(statusbar_NASMFLAGS) $< -o $@
	
statusbar$(EXEEXT): $(bin_PROGRAMS).o
	ld $(statusbar_LDFLAGS) $(statusbar_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(statusbar_OBJS) $(bin_PROGRAMS)$(EXEEXT)
