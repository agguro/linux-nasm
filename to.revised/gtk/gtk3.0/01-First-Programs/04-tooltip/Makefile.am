NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = tooltip
tooltip_NASMFLAGS = @PACKAGE_NASMFLAGS@
tooltip_LDFLAGS = @PACKAGE_LDFLAGS@
tooltip_LIBS = @PACKAGE_LIBS@
tooltip_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(tooltip_NASMFLAGS) $< -o $@
	
tooltip$(EXEEXT): $(bin_PROGRAMS).o
	ld $(tooltip_LDFLAGS) $(tooltip_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(tooltip_OBJS) $(bin_PROGRAMS)$(EXEEXT)
