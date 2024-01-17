
CC = gcc

all: packtable packbox

packtable : packtable.c 
	$(CC) -o packtable packtable.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0`
packbox : packbox.c 
	$(CC) -o packbox packbox.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0`
clean: 
	rm -f *.o packtable packbox
