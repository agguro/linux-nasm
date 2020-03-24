NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = center
center_NASMFLAGS = @PACKAGE_NASMFLAGS@
center_LDFLAGS = @PACKAGE_LDFLAGS@
center_LIBS = @PACKAGE_LIBS@
center_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(center_NASMFLAGS) $< -o $@
	
center$(EXEEXT): $(bin_PROGRAMS).o
	ld $(center_LDFLAGS) $(center_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(center_OBJS) $(bin_PROGRAMS)$(EXEEXT)
