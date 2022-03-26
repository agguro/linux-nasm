NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = cpuWidget
cpuWidget_NASMFLAGS = @PACKAGE_NASMFLAGS@
cpuWidget_LDFLAGS = @PACKAGE_LDFLAGS@
cpuWidget_LIBS = @PACKAGE_LIBS@
cpuWidget_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(cpuWidget_NASMFLAGS) $< -o $@
	
cpuWidget$(EXEEXT): $(bin_PROGRAMS).o
	ld $(cpuWidget_LDFLAGS) $(cpuWidget_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(cpuWidget_OBJS) $(bin_PROGRAMS)$(EXEEXT)
