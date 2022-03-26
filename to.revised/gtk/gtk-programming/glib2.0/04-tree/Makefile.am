NASM = /usr/bin/nasm
LD   = /usr/bin/ld

bin_PROGRAMS = tree

tree_NASMFLAGS = @PACKAGE_NASMFLAGS@
tree_LDFLAGS = @PACKAGE_LDFLAGS@
tree_LIBS = @PACKAGE_LIBS@
tree_OBJS = main.o

.asm.o:
	$(NASM) $(tree_NASMFLAGS) $< -o $@
	
tree$(EXEEXT): $(tree_OBJS)
	ld $(tree_LDFLAGS) $(tree_LIBS) $(tree_OBJS) -o $(bin_PROGRAMS)
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAM)_OBJS) $(tree_OBJS) $(bin_PROGRAMS)$(EXEEXT)