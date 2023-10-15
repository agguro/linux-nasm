NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = checkbutton
checkbutton_NASMFLAGS = @PACKAGE_NASMFLAGS@
checkbutton_LDFLAGS = @PACKAGE_LDFLAGS@
checkbutton_LIBS = @PACKAGE_LIBS@
checkbutton_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(checkbutton_NASMFLAGS) $< -o $@
	
checkbutton$(EXEEXT): $(bin_PROGRAMS).o
	ld $(checkbutton_LDFLAGS) $(checkbutton_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(checkbutton_OBJS) $(bin_PROGRAMS)$(EXEEXT)
