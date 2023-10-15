NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = label
label_NASMFLAGS = @PACKAGE_NASMFLAGS@
label_LDFLAGS = @PACKAGE_LDFLAGS@
label_LIBS = @PACKAGE_LIBS@
label_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(label_NASMFLAGS) $< -o $@
	
label$(EXEEXT): $(bin_PROGRAMS).o
	ld $(label_LDFLAGS) $(label_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(label_OBJS) $(bin_PROGRAMS)$(EXEEXT)
