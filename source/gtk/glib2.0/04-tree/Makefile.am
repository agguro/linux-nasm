NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = tree
tree_NASMFLAGS = @PACKAGE_NASMFLAGS@
tree_LDFLAGS = @PACKAGE_LDFLAGS@
tree_LIBS = @PACKAGE_LIBS@
tree_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(tree_NASMFLAGS) $< -o $@
	
tree$(EXEEXT): $(bin_PROGRAMS).o
	ld $(tree_LDFLAGS) $(tree_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(tree_OBJS) $(bin_PROGRAMS)$(EXEEXT)
