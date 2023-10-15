NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = combobox
combobox_NASMFLAGS = @PACKAGE_NASMFLAGS@
combobox_LDFLAGS = @PACKAGE_LDFLAGS@
combobox_LIBS = @PACKAGE_LIBS@
combobox_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(combobox_NASMFLAGS) $< -o $@
	
combobox$(EXEEXT): $(bin_PROGRAMS).o
	ld $(combobox_LDFLAGS) $(combobox_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $(combobox_OBJS) $(bin_PROGRAMS)$(EXEEXT)
