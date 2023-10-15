NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = fontdialog
fontdialog_NASMFLAGS = @PACKAGE_NASMFLAGS@
fontdialog_LDFLAGS = @PACKAGE_LDFLAGS@
fontdialog_LIBS = @PACKAGE_LIBS@
fontdialog_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(fontdialog_NASMFLAGS) $< -o $@
	
fontdialog$(EXEEXT): $(bin_PROGRAMS).o
	ld $(fontdialog_LDFLAGS) $(fontdialog_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(fontdialog_OBJS) $(bin_PROGRAMS)$(EXEEXT)
