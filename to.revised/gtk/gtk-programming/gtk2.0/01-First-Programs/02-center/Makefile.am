NASM = /usr/bin/nasm
LD   = /usr/bin/ld

bin_PROGRAMS = center

center_NASMFLAGS = @PACKAGE_NASMFLAGS@
center_LDFLAGS = @PACKAGE_LDFLAGS@
center_LIBS = @PACKAGE_LIBS@
center_OBJS = main.o

.asm.o:
	$(NASM) $(center_NASMFLAGS) $< -o $@
	
center$(EXEEXT): $(center_OBJS)
	ld $(center_LDFLAGS) $(center_LIBS) $(center_OBJS) -o $(bin_PROGRAMS)
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAM)_OBJS) $(center_OBJS) $(bin_PROGRAMS)$(EXEEXT)
