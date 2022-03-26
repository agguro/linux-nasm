NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = popupmenu
popupmenu_NASMFLAGS = @PACKAGE_NASMFLAGS@
popupmenu_LDFLAGS = @PACKAGE_LDFLAGS@
popupmenu_LIBS = @PACKAGE_LIBS@
popupmenu_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(popupmenu_NASMFLAGS) $< -o $@
	
popupmenu$(EXEEXT): $(bin_PROGRAMS).o
	ld $(popupmenu_LDFLAGS) $(popupmenu_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(popupmenu_OBJS) $(bin_PROGRAMS)$(EXEEXT)
