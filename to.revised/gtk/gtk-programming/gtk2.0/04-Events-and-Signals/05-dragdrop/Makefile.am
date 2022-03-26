NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = dragdrop
dragdrop_NASMFLAGS = @PACKAGE_NASMFLAGS@
dragdrop_LDFLAGS = @PACKAGE_LDFLAGS@
dragdrop_LIBS = @PACKAGE_LIBS@
dragdrop_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(dragdrop_NASMFLAGS) $< -o $@
	
dragdrop$(EXEEXT): $(bin_PROGRAMS).o
	ld $(dragdrop_LDFLAGS) $(dragdrop_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(dragdrop_OBJS) $(bin_PROGRAMS)$(EXEEXT)
