NASM = /usr/bin/nasm
LD   = /usr/bin/ld

bin_PROGRAMS = list

list_NASMFLAGS = @PACKAGE_NASMFLAGS@
list_LDFLAGS = @PACKAGE_LDFLAGS@
list_LIBS = @PACKAGE_LIBS@
list_OBJS = main.o

.asm.o:
	$(NASM) $(list_NASMFLAGS) $< -o $@
	
list$(EXEEXT): $(list_OBJS)
	ld $(list_LDFLAGS) $(list_LIBS) $(list_OBJS) -o $(bin_PROGRAMS)
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAM)_OBJS) $(list_OBJS) $(bin_PROGRAMS)$(EXEEXT)
