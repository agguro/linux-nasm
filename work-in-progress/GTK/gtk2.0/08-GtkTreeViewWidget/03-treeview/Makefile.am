NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = treeview
version_NASMFLAGS = @PACKAGE_NASMFLAGS@
version_LDFLAGS = @PACKAGE_LDFLAGS@
version_LIBS = @PACKAGE_LIBS@
version_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(treeview_NASMFLAGS) $< -o $@
	
version$(EXEEXT): $(bin_PROGRAMS).o
	ld $(treeview_LDFLAGS) $(treeview_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(treeview_OBJS) $(bin_PROGRAMS)$(EXEEXT)
