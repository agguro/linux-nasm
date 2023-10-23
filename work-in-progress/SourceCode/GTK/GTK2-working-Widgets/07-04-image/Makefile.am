NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = image
image_NASMFLAGS = @PACKAGE_NASMFLAGS@
image_LDFLAGS = @PACKAGE_LDFLAGS@
image_LIBS = @PACKAGE_LIBS@
image_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(image_NASMFLAGS) $< -o $@
	
image$(EXEEXT): $(bin_PROGRAMS).o
	ld $(image_LDFLAGS) $(image_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(image_OBJS) $(bin_PROGRAMS)$(EXEEXT)
