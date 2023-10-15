
CC = gcc -Wall

all: minesweeper

minesweeper: minesweeper.c misc.c menu.c digits.h timer.c showmessage.c about.c
	$(CC) `pkg-config --cflags gtk+-2.0` -o minesweeper minesweeper.c misc.c menu.c timer.c showmessage.c about.c `pkg-config --libs gtk+-2.0` 
clean: 
	rm -f *.o minesweeper
