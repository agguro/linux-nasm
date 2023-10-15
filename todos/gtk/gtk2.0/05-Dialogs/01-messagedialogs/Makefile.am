NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = messagedialogs
messagedialogs_NASMFLAGS = @PACKAGE_NASMFLAGS@
messagedialogs_LDFLAGS = @PACKAGE_LDFLAGS@
messagedialogs_LIBS = @PACKAGE_LIBS@
messagedialogs_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(messagedialogs_NASMFLAGS) $< -o $@
	
messagedialogs$(EXEEXT): $(bin_PROGRAMS).o
	ld $(messagedialogs_LDFLAGS) $(messagedialogs_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(messagedialogs_OBJS) $(bin_PROGRAMS)$(EXEEXT)
