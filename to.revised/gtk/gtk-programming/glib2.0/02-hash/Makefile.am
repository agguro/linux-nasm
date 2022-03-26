NASM = /usr/bin/nasm
LD   = /usr/bin/ld

bin_PROGRAMS = hash

hash_NASMFLAGS = @PACKAGE_NASMFLAGS@
hash_LDFLAGS = @PACKAGE_LDFLAGS@
hash_LIBS = @PACKAGE_LIBS@
hash_OBJS = main.o

.asm.o:
	$(NASM) $(hash_NASMFLAGS) $< -o $@
	
hash$(EXEEXT): $(hash_OBJS)
	ld $(hash_LDFLAGS) $(hash_LIBS) $(hash_OBJS) -o $(bin_PROGRAMS)
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAM)_OBJS) $(hash_OBJS) $(bin_PROGRAMS)$(EXEEXT)