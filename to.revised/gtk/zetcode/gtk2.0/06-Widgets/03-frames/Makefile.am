NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = frame
frame_NASMFLAGS = @PACKAGE_NASMFLAGS@
frame_LDFLAGS = @PACKAGE_LDFLAGS@
frame_LIBS = @PACKAGE_LIBS@
frame_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(frame_NASMFLAGS) $< -o $@
	
frame$(EXEEXT): $(bin_PROGRAMS).o
	ld $(frame_LDFLAGS) $(frame_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(frame_OBJS) $(bin_PROGRAMS)$(EXEEXT)
