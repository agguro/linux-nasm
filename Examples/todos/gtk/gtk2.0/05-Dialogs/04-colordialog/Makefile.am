NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = colordialog
colordialog_NASMFLAGS = @PACKAGE_NASMFLAGS@
colordialog_LDFLAGS = @PACKAGE_LDFLAGS@
colordialog_LIBS = @PACKAGE_LIBS@
colordialog_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(colordialog_NASMFLAGS) $< -o $@
	
colordialog$(EXEEXT): $(bin_PROGRAMS).o
	ld $(colordialog_LDFLAGS) $(colordialog_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(colordialog_OBJS) $(bin_PROGRAMS)$(EXEEXT)
