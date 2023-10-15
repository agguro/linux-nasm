NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = entersignal
entersignal_NASMFLAGS = @PACKAGE_NASMFLAGS@
entersignal_LDFLAGS = @PACKAGE_LDFLAGS@
entersignal_LIBS = @PACKAGE_LIBS@
entersignal_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(entersignal_NASMFLAGS) $< -o $@
	
entersignal$(EXEEXT): $(bin_PROGRAMS).o
	ld $(entersignal_LDFLAGS) $(entersignal_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(entersignal_OBJS) $(bin_PROGRAMS)$(EXEEXT)
