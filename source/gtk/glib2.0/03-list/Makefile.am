NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = list
list_NASMFLAGS = @PACKAGE_NASMFLAGS@
list_LDFLAGS = @PACKAGE_LDFLAGS@
list_LIBS = @PACKAGE_LIBS@
list_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(list_NASMFLAGS) $< -o $@
	
list$(EXEEXT): $(bin_PROGRAMS).o
	ld $(list_LDFLAGS) $(list_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(list_OBJS) $(bin_PROGRAMS)$(EXEEXT)
