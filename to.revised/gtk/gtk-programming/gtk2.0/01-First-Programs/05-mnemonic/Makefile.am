NASM = /usr/bin/nasm
LD   = /usr/bin/ld

bin_PROGRAMS = mnemonic

mnemonic_NASMFLAGS = @PACKAGE_NASMFLAGS@
mnemonic_LDFLAGS = @PACKAGE_LDFLAGS@
mnemonic_LIBS = @PACKAGE_LIBS@
mnemonic_OBJS = main.o

.asm.o:
	$(NASM) $(mnemonic_NASMFLAGS) $< -o $@
	
mnemonic$(EXEEXT): $(mnemonic_OBJS)
	ld $(mnemonic_LDFLAGS) $(mnemonic_LIBS) $(mnemonic_OBJS) -o $(bin_PROGRAMS)
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAM)_OBJS) $(mnemonic_OBJS) $(bin_PROGRAMS)$(EXEEXT)
