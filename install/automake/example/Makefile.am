NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = hello
hello_NASMFLAGS = @PACKAGE_NASMFLAGS@
hello_LDFLAGS = @PACKAGE_LDFLAGS@ -no-pie
hello_SOURCES = hello.asm

.asm.o:
	$(NASM) $(hello_NASMFLAGS) $< -o $@
	
hello$(EXEEXT): hello.o
	ld $(LDFLAGS) $^ -o $@
	
no-debug: hello
	strip -s hello
	
clean:
	rm -rf $(hello_OBJS) hello$(EXEEXT)
