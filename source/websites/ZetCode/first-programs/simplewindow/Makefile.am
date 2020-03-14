NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = simplewindow
simplewindow_NASMFLAGS = @PACKAGE_NASMFLAGS@
simplewindow_LDFLAGS = @PACKAGE_LDFLAGS@
simplewindow_LIBS = @PACKAGE_LIBS@
simplewindow_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(simplewindow_NASMFLAGS) $< -o $@
	
simplewindow$(EXEEXT): $(bin_PROGRAMS).o
	ld $(simplewindow_LDFLAGS) $(simplewindow_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(hello_OBJS) $(bin_PROGRAMS)$(EXEEXT)
