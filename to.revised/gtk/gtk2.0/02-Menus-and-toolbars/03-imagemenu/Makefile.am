NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = imagemenu
imagemenu_NASMFLAGS = @PACKAGE_NASMFLAGS@
imagemenu_LDFLAGS = @PACKAGE_LDFLAGS@
imagemenu_LIBS = @PACKAGE_LIBS@
imagemenu_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(imagemenu_NASMFLAGS) $< -o $@
	
imagemenu$(EXEEXT): $(bin_PROGRAMS).o
	ld $(imagemenu_LDFLAGS) $(imagemenu_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(imagemenu_OBJS) $(bin_PROGRAMS)$(EXEEXT)
