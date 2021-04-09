NASM = /usr/bin/nasm
LD   = /usr/bin/ld
bin_PROGRAMS = sslsocket

sslsocket_NASMFLAGS = -f elf64 -F dwarf -g
sslsocket_LDFLAGS = -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2
sslsocket_LIBS = `pkg-config --libs openssl`
sslsocket_SOURCES = sslsocket.asm sslsocket.inc

.asm.o:
	$(NASM) $(sslsocket_NASMFLAGS) $< -o $@
	
sslsocket$(EXEEXT): $(bin_PROGRAMS).o
	ld $(sslsocket_LDFLAGS) $(sslsocket_LIBS) $^ -o $@

debug:
	$(MAKE)

release: $(bin_PROGRAMS)$(EXEEXT)
	$(MAKE)
	strip -s $(bin_PROGRAMS)$(EXEEXT)

strip:
	strip -s $(bin_PROGRAMS)$(EXEEXT)

clean:
	rm -rf $(sslsocket_OBJS) $(bin_PROGRAMS)$(EXEEXT)