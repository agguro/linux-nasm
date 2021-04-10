BIN=httpserver sslsocket sockettest

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g
DYN=--dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS=`pkg-config --libs openssl`

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(BIN) *.o

httpserver.o: httpserver.asm
	$(NASM) $(NASMOPTS) httpserver.asm -o httpserver.o
	
httpserver: httpserver.o
	$(LD) $(LDOPS) -o httpserver httpserver.o

sslsocket.o: sslsocket.asm sslsocket.inc
	$(NASM) $(NASMOPTS) sslsocket.asm -o sslsocket.o

sslsocket: sslsocket.o
	$(LD) $(DYN) $(LDOPS) -o sslsocket sslsocket.o $(LIBS)

sockettest.o: sockettest.asm
	$(NASM) $(NASMOPTS) sockettest.asm -o sockettest.o

sockettest: sockettest.o
	$(LD) $(LDOPS) -o sockettest sockettest.o
