NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = fixed
fixed_NASMFLAGS = @PACKAGE_NASMFLAGS@
fixed_LDFLAGS = @PACKAGE_LDFLAGS@
fixed_LIBS = @PACKAGE_LIBS@
fixed_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(fixed_NASMFLAGS) $< -o $@
	
fixed$(EXEEXT): $(bin_PROGRAMS).o
	ld $(fixed_LDFLAGS) $(fixed_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(fixed_OBJS) $(bin_PROGRAMS)$(EXEEXT)
