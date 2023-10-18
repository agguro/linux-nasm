
CC = gcc

PROGS = sortlist tree hash message list mem

all: $(PROGS)

sortlist: sortlist.c 
	$(CC) `pkg-config --libs --cflags gtk+-2.0` sortlist.c -o sortlist 

tree: tree.c 
	$(CC) `pkg-config --libs --cflags gtk+-2.0` tree.c -o tree 

hash: hash.c
	$(CC) `pkg-config --libs --cflags gtk+-2.0` hash.c -o hash 

message: message.c
	$(CC) `pkg-config --libs --cflags gtk+-2.0` message.c -o message 

list: list.c
	$(CC) `pkg-config --libs --cflags gtk+-2.0` list.c -o list 

mem: mem.c
	$(CC) `pkg-config --libs --cflags gtk+-2.0` mem.c -o mem 

IGNORED = *.o $(PROGS)

.PHONY:
ignored:
	@echo $(IGNORED)

.PHONY:
clean:
	rm -f *.o $(PROGS)
