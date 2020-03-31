NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = waitforenterkeypress
waitforenterkeypress_NASMFLAGS = @PACKAGE_NASMFLAGS@
waitforenterkeypress_LDFLAGS = @PACKAGE_LDFLAGS@
waitforenterkeypress_LIBS = @PACKAGE_LIBS@
waitforenterkeypress_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(waitforenterkeypress_NASMFLAGS) $< -o $@
	
waitforenterkeypress$(EXEEXT): $(bin_PROGRAMS).o
	ld $(waitforenterkeypress_LDFLAGS) $(waitforenterkeypress_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(waitforenterkeypress_OBJS) $(bin_PROGRAMS)$(EXEEXT)
