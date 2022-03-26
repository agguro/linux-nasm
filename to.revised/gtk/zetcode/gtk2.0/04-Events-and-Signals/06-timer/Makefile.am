NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = timer
timer_NASMFLAGS = @PACKAGE_NASMFLAGS@
timer_LDFLAGS = @PACKAGE_LDFLAGS@
timer_LIBS = @PACKAGE_LIBS@
timer_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(timer_NASMFLAGS) $< -o $@
	
timer$(EXEEXT): $(bin_PROGRAMS).o
	ld $(timer_LDFLAGS) $(timer_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(timer_OBJS) $(bin_PROGRAMS)$(EXEEXT)
