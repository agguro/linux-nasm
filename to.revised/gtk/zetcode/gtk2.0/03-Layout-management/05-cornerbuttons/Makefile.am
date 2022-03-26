NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = cornerbuttons
cornerbuttons_NASMFLAGS = @PACKAGE_NASMFLAGS@
cornerbuttons_LDFLAGS = @PACKAGE_LDFLAGS@
cornerbuttons_LIBS = @PACKAGE_LIBS@
cornerbuttons_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(cornerbuttons_NASMFLAGS) $< -o $@
	
cornerbuttons$(EXEEXT): $(bin_PROGRAMS).o
	ld $(cornerbuttons_LDFLAGS) $(cornerbuttons_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(cornerbuttons_OBJS) $(bin_PROGRAMS)$(EXEEXT)
