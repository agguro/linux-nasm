NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = simple
simple_NASMFLAGS = @PACKAGE_NASMFLAGS@
simple_LDFLAGS = @PACKAGE_LDFLAGS@
simple_LIBS = @PACKAGE_LIBS@

simple_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(simple_NASMFLAGS) $< -o $@
	
simple$(EXEEXT): $(bin_PROGRAMS).o
	ld $(simple_LDFLAGS) $(simple_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(simple_OBJS) $(bin_PROGRAMS)$(EXEEXT)
