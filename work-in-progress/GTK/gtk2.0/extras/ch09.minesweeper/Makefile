
CC = gcc -Wall

all: minesweeper

minesweeper: minesweeper.c misc.c menu.c digits.h timer.c showmessage.c about.c
	$(CC) `pkg-config --cflags --libs gtk+-3.0` minesweeper.c misc.c menu.c timer.c showmessage.c about.c -o minesweeper

clean: 
	rm -f *.o minesweeper
