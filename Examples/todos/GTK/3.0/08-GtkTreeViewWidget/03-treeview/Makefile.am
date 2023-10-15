NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = version
version_NASMFLAGS = @PACKAGE_NASMFLAGS@
version_LDFLAGS = @PACKAGE_LDFLAGS@
version_LIBS = @PACKAGE_LIBS@
version_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(version_NASMFLAGS) $< -o $@
	
version$(EXEEXT): $(bin_PROGRAMS).o
	ld $(version_LDFLAGS) $(version_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(version_OBJS) $(bin_PROGRAMS)$(EXEEXT)
