NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = icon
icon_NASMFLAGS = @PACKAGE_NASMFLAGS@
icon_LDFLAGS = @PACKAGE_LDFLAGS@
icon_LIBS = @PACKAGE_LIBS@
icon_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(icon_NASMFLAGS) $< -o $@
	
icon$(EXEEXT): $(bin_PROGRAMS).o
	ld $(icon_LDFLAGS) $(icon_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(icon_OBJS) $(bin_PROGRAMS)$(EXEEXT)
