NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = hash
hash_NASMFLAGS = @PACKAGE_NASMFLAGS@
hash_LDFLAGS = @PACKAGE_LDFLAGS@
hash_LIBS = @PACKAGE_LIBS@
hash_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(hash_NASMFLAGS) $< -o $@
	
hash$(EXEEXT): $(bin_PROGRAMS).o
	ld $(hash_LDFLAGS) $(hash_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(hash_OBJS) $(bin_PROGRAMS)$(EXEEXT)
