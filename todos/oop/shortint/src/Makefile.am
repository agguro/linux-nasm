NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = oop
oop_NASMFLAGS = @PACKAGE_NASMFLAGS@
oop_LDFLAGS = @PACKAGE_LDFLAGS@
oop_LIBS = @PACKAGE_LIBS@

oop_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(oop_NASMFLAGS) $< -o $@
	
oop$(EXEEXT): $(bin_PROGRAMS).o
	ld $(oop_LDFLAGS) $(oop_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(oop_OBJS) $(bin_PROGRAMS)$(EXEEXT)
