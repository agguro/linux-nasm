NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = appiconmem
appiconmem_NASMFLAGS = @PACKAGE_NASMFLAGS@
appiconmem_LDFLAGS = @PACKAGE_LDFLAGS@
appiconmem_LIBS = @PACKAGE_LIBS@
appiconmem_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(appiconmem_NASMFLAGS) $< -o $@
	
appiconmem$(EXEEXT): $(bin_PROGRAMS).o
	ld $(appiconmem_LDFLAGS) $(appiconmem_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(appiconmem_OBJS) $(bin_PROGRAMS)$(EXEEXT)
