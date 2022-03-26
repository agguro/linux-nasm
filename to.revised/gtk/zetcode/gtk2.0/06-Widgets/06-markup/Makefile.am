NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = markup
markup_NASMFLAGS = @PACKAGE_NASMFLAGS@
markup_LDFLAGS = @PACKAGE_LDFLAGS@
markup_LIBS = @PACKAGE_LIBS@
markup_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(markup_NASMFLAGS) $< -o $@
	
markup$(EXEEXT): $(bin_PROGRAMS).o
	ld $(markup_LDFLAGS) $(markup_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(markup_OBJS) $(bin_PROGRAMS)$(EXEEXT)
