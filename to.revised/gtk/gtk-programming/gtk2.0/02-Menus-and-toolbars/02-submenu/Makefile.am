NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = submenu
submenu_NASMFLAGS = @PACKAGE_NASMFLAGS@
submenu_LDFLAGS = @PACKAGE_LDFLAGS@
submenu_LIBS = @PACKAGE_LIBS@
submenu_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(submenu_NASMFLAGS) $< -o $@
	
submenu$(EXEEXT): $(bin_PROGRAMS).o
	ld $(submenu_LDFLAGS) $(submenu_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(submenu_OBJS) $(bin_PROGRAMS)$(EXEEXT)
