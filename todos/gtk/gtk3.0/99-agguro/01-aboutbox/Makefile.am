NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = aboutbox
aboutbox_NASMFLAGS = @PACKAGE_NASMFLAGS@
aboutbox_LDFLAGS = @PACKAGE_LDFLAGS@
aboutbox_LIBS = @PACKAGE_LIBS@
aboutbox_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(aboutbox_NASMFLAGS) $< -o $@
	
aboutbox$(EXEEXT): $(bin_PROGRAMS).o
	ld $(aboutbox_LDFLAGS) $(aboutbox_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(aboutbox_OBJS) $(bin_PROGRAMS)$(EXEEXT)
