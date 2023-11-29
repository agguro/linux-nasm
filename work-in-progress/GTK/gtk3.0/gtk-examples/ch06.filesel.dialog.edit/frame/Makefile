CC = gcc

frame: frame.c 
	$(CC) `gtk-config --cflags` `pkg-config --libs gtk+-2.0` frame.c -o frame

clean: 
	rm -f *.o frame
