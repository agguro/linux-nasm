NASM = /usr/bin/nasm
LD   = /usr/bin/ld

bin_PROGRAMS = icon

icon_NASMFLAGS = @PACKAGE_NASMFLAGS@
icon_LDFLAGS = @PACKAGE_LDFLAGS@
icon_LIBS = @PACKAGE_LIBS@
icon_OBJS = main.o

.asm.o:
	$(NASM) $(icon_NASMFLAGS) $< -o $@
	
icon$(EXEEXT): $(icon_OBJS)
	ld $(icon_LDFLAGS) $(icon_LIBS) $(icon_OBJS) -o $(bin_PROGRAMS)
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAM)_OBJS) $(icon_OBJS) $(bin_PROGRAMS)$(EXEEXT)
