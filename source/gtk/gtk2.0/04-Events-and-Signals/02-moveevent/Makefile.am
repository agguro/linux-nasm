NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = moveevent
moveevent_NASMFLAGS = @PACKAGE_NASMFLAGS@
moveevent_LDFLAGS = @PACKAGE_LDFLAGS@
moveevent_LIBS = @PACKAGE_LIBS@
moveevent_SOURCES = $(bin_PROGRAMS).asm

.asm.o:
	$(NASM) $(moveevent_NASMFLAGS) $< -o $@
	
$(bin_PROGRAMS)$(EXEEXT): $(bin_PROGRAMS).o
	ld $(moveevent_LDFLAGS) $(moveevent_LIBS) $^ -o $@
	
no-debug: $(bin_PROGRAMS)$(EXEEXT)
	strip -s $(bin_PROGRAMS)$(EXEEXT)
	
clean:
	rm -rf $($(bin_PROGRAMS)_OBJS) $(bin_PROGRAMS)$(EXEEXT)
