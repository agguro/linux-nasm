
CC = gcc 

all: graphit

main.o: main.c 
	$(CC) -c -g main.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0`

gtkgraph.o: gtkgraph.c 
	$(CC) -c -g gtkgraph.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0`

graphit: gtkgraph.o main.o
	$(CC) -g gtkgraph.o main.o -o graphit `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0`

clean: 
	rm -f *.o graphit
