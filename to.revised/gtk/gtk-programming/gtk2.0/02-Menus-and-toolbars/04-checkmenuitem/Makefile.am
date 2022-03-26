NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = checkmenuitem
checkmenuitem_NASMFLAGS = @PACKAGE_NASMFLAGS@
checkmenuitem_LDFLAGS = @PACKAGE_LDFLAGS@
checkmenuitem_LIBS = @PACKAGE_LIBS@
checkmenuitem_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(checkmenuitem_NASMFLAGS) $< -o $@
	
checkmenuitem$(EXEEXT): $(bin_PROGRAMS).o
	ld $(checkmenuitem_LDFLAGS) $(checkmenuitem_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(checkmenuitem_OBJS) $(bin_PROGRAMS)$(EXEEXT)
