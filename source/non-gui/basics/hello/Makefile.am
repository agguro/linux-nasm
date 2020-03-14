NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = hello$(EXEEXT)
hello_SOURCES = hello.asm
hello_OBJS = hello.o
hello_NASMFLAGS = @PACKAGE_NASMFLAGS@
hello_LDFLAGS = @PACKAGE_LDFLAGS@

.asm.o:
	$(NASM) $(hello_NASMFLAGS) $< -o $@

hello$(EXEEXT): $(hello_OBJS)
	ld $(hello_LDFLAGS) $^ -o $@

clean:
	rm -f $(hello_OBJS) $(bin_PROGRAMS)
