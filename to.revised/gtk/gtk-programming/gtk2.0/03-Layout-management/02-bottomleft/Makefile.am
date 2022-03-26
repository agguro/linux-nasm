NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = bottomleft
bottomleft_NASMFLAGS = @PACKAGE_NASMFLAGS@
bottomleft_LDFLAGS = @PACKAGE_LDFLAGS@
bottomleft_LIBS = @PACKAGE_LIBS@
bottomleft_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(bottomleft_NASMFLAGS) $< -o $@
	
bottomleft$(EXEEXT): $(bin_PROGRAMS).o
	ld $(bottomleft_LDFLAGS) $(bottomleft_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(bottomleft_OBJS) $(bin_PROGRAMS)$(EXEEXT)
