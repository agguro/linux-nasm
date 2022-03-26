NASM = /usr/bin/nasm
LD   = /usr/bin/ld

bin_PROGRAMS = tooltip

tooltip_NASMFLAGS = @PACKAGE_NASMFLAGS@
tooltip_LDFLAGS = @PACKAGE_LDFLAGS@
tooltip_LIBS = @PACKAGE_LIBS@
tooltip_OBJS = main.o

.asm.o:
	$(NASM) $(tooltip_NASMFLAGS) $< -o $@
	
tooltip$(EXEEXT): $(tooltip_OBJS)
	ld $(tooltip_LDFLAGS) $(tooltip_LIBS) $(tooltip_OBJS) -o $(bin_PROGRAMS)
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAM)_OBJS) $(tooltip_OBJS) $(bin_PROGRAMS)$(EXEEXT)
