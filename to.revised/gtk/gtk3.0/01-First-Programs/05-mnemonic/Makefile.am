NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = mnemonic
mnemonic_NASMFLAGS = @PACKAGE_NASMFLAGS@
mnemonic_LDFLAGS = @PACKAGE_LDFLAGS@
mnemonic_LIBS = @PACKAGE_LIBS@
mnemonic_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(mnemonic_NASMFLAGS) $< -o $@
	
mnemonic$(EXEEXT): $(bin_PROGRAMS).o
	ld $(mnemonic_LDFLAGS) $(mnemonic_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(mnemonic_OBJS) $(bin_PROGRAMS)$(EXEEXT)
