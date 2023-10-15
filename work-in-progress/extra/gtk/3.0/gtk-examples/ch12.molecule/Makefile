
CC = gcc -Wall

all: molecule 

molecule.o: molecule.c
	$(CC) -c -g molecule.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0` 

matrix3d.o: matrix3d.c
	$(CC) -c -g matrix3d.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0` 

frontend.o: frontend.c
	$(CC) -c -g frontend.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0` 

misc.o: misc.c
	$(CC) -c -g misc.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0` 

filesel.o: filesel.c
	$(CC) -c -g filesel.c `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0` 

molecule: molecule.o matrix3d.o frontend.o misc.o filesel.o
	$(CC) -Wall -g -o molecule molecule.o matrix3d.o frontend.o misc.o filesel.o  `pkg-config --cflags gtk+-2.0 --libs gtk+-2.0` -lm

clean: 
	rm -f *.o molecule
