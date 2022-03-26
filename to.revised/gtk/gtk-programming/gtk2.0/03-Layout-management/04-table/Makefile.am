NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = table
table_NASMFLAGS = @PACKAGE_NASMFLAGS@
table_LDFLAGS = @PACKAGE_LDFLAGS@
table_LIBS = @PACKAGE_LIBS@
table_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(table_NASMFLAGS) $< -o $@
	
table$(EXEEXT): $(bin_PROGRAMS).o
	ld $(table_LDFLAGS) $(table_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(table_OBJS) $(bin_PROGRAMS)$(EXEEXT)
