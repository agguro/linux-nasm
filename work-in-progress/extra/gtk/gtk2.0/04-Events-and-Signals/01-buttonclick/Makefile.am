NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = buttonclick
buttonclick_NASMFLAGS = @PACKAGE_NASMFLAGS@
buttonclick_LDFLAGS = @PACKAGE_LDFLAGS@
buttonclick_LIBS = @PACKAGE_LIBS@
buttonclick_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(buttonclick_NASMFLAGS) $< -o $@
	
buttonclick$(EXEEXT): $(bin_PROGRAMS).o
	ld $(buttonclick_LDFLAGS) $(buttonclick_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(buttonclick_OBJS) $(bin_PROGRAMS)$(EXEEXT)
