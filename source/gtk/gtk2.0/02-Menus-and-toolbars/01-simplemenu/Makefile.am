NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = simplemenu
simplemenu_NASMFLAGS = @PACKAGE_NASMFLAGS@
simplemenu_LDFLAGS = @PACKAGE_LDFLAGS@
simplemenu_LIBS = @PACKAGE_LIBS@
simplemenu_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(simplemenu_NASMFLAGS) $< -o $@
	
simplemenu$(EXEEXT): $(bin_PROGRAMS).o
	ld $(simplemenu_LDFLAGS) $(simplemenu_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(simplemenu_OBJS) $(bin_PROGRAMS)$(EXEEXT)
