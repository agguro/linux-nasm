NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = incdec
incdec_NASMFLAGS = @PACKAGE_NASMFLAGS@
incdec_LDFLAGS = @PACKAGE_LDFLAGS@
incdec_LIBS = @PACKAGE_LIBS@
incdec_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(incdec_NASMFLAGS) $< -o $@
	
incdec$(EXEEXT): $(bin_PROGRAMS).o
	ld $(incdec_LDFLAGS) $(incdec_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(incdec_OBJS) $(bin_PROGRAMS)$(EXEEXT)
