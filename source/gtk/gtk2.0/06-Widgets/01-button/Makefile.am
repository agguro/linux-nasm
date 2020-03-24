NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = button
button_NASMFLAGS = @PACKAGE_NASMFLAGS@
button_LDFLAGS = @PACKAGE_LDFLAGS@
button_LIBS = @PACKAGE_LIBS@
button_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(button_NASMFLAGS) $< -o $@
	
button$(EXEEXT): $(bin_PROGRAMS).o
	ld $(button_LDFLAGS) $(button_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(button_OBJS) $(bin_PROGRAMS)$(EXEEXT)
