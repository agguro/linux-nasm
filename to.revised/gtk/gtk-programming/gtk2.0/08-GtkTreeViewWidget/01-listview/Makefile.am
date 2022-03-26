NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = listview
listview_NASMFLAGS = @PACKAGE_NASMFLAGS@
listview_LDFLAGS = @PACKAGE_LDFLAGS@
listview_LIBS = @PACKAGE_LIBS@
listview_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(listview_NASMFLAGS) $< -o $@
	
listview$(EXEEXT): $(bin_PROGRAMS).o
	ld $(listview_LDFLAGS) $(listview_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(listview_OBJS) $(bin_PROGRAMS)$(EXEEXT)
