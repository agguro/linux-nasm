NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = windows
windows_NASMFLAGS = @PACKAGE_NASMFLAGS@
windows_LDFLAGS = @PACKAGE_LDFLAGS@
windows_LIBS = @PACKAGE_LIBS@
windows_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(windows_NASMFLAGS) $< -o $@
	
windows$(EXEEXT): $(bin_PROGRAMS).o
	ld $(windows_LDFLAGS) $(windows_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(windows_OBJS) $(bin_PROGRAMS)$(EXEEXT)
