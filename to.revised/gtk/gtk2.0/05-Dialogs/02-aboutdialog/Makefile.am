NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = aboutdialog
aboutdialog_NASMFLAGS = @PACKAGE_NASMFLAGS@
aboutdialog_LDFLAGS = @PACKAGE_LDFLAGS@
aboutdialog_LIBS = @PACKAGE_LIBS@
aboutdialog_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(aboutdialog_NASMFLAGS) $< -o $@
	
aboutdialog$(EXEEXT): $(bin_PROGRAMS).o
	ld $(aboutdialog_LDFLAGS) $(aboutdialog_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(aboutdialog_OBJS) $(bin_PROGRAMS)$(EXEEXT)
