NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = hscale
hscale_NASMFLAGS = @PACKAGE_NASMFLAGS@
hscale_LDFLAGS = @PACKAGE_LDFLAGS@
hscale_LIBS = @PACKAGE_LIBS@
hscale_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(hscale_NASMFLAGS) $< -o $@
	
hscale$(EXEEXT): $(bin_PROGRAMS).o
	ld $(hscale_LDFLAGS) $(hscale_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(hscale_OBJS) $(bin_PROGRAMS)$(EXEEXT)
