NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = vbox
vbox_NASMFLAGS = @PACKAGE_NASMFLAGS@
vbox_LDFLAGS = @PACKAGE_LDFLAGS@
vbox_LIBS = @PACKAGE_LIBS@
vbox_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(vbox_NASMFLAGS) $< -o $@
	
vbox$(EXEEXT): $(bin_PROGRAMS).o
	ld $(vbox_LDFLAGS) $(vbox_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(vbox_OBJS) $(bin_PROGRAMS)$(EXEEXT)
