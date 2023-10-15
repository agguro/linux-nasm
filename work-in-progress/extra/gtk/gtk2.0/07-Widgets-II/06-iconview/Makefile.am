NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = iconview
iconview_NASMFLAGS = @PACKAGE_NASMFLAGS@
iconview_LDFLAGS = @PACKAGE_LDFLAGS@
iconview_LIBS = @PACKAGE_LIBS@
iconview_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(iconview_NASMFLAGS) $< -o $@
	
iconview$(EXEEXT): $(bin_PROGRAMS).o
	ld $(iconview_LDFLAGS) $(iconview_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(iconview_OBJS) $(bin_PROGRAMS)$(EXEEXT)
