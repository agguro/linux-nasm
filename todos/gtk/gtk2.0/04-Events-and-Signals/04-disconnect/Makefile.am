NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = disconnect
disconnect_NASMFLAGS = @PACKAGE_NASMFLAGS@
disconnect_LDFLAGS = @PACKAGE_LDFLAGS@
disconnect_LIBS = @PACKAGE_LIBS@
disconnect_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(disconnect_NASMFLAGS) $< -o $@
	
disconnect$(EXEEXT): $(bin_PROGRAMS).o
	ld $(disconnect_LDFLAGS) $(disconnect_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(disconnect_OBJS) $(bin_PROGRAMS)$(EXEEXT)
