NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = undoredo
undoredo_NASMFLAGS = @PACKAGE_NASMFLAGS@
undoredo_LDFLAGS = @PACKAGE_LDFLAGS@
undoredo_LIBS = @PACKAGE_LIBS@
undoredo_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(undoredo_NASMFLAGS) $< -o $@
	
undoredo$(EXEEXT): $(bin_PROGRAMS).o
	ld $(undoredo_LDFLAGS) $(undoredo_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(undoredo_OBJS) $(bin_PROGRAMS)$(EXEEXT)
