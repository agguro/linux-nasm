NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = aggdialog
aggdialog_NASMFLAGS = @PACKAGE_NASMFLAGS@
aggdialog_LDFLAGS = @PACKAGE_LDFLAGS@
aggdialog_LIBS = @PACKAGE_LIBS@
aggdialog_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(aggdialog_NASMFLAGS) $< -o $@
	
aggdialog$(EXEEXT): $(bin_PROGRAMS).o
	ld $(aggdialog_LDFLAGS) $(aggdialog_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(aggdialog_OBJS) $(bin_PROGRAMS)$(EXEEXT)
