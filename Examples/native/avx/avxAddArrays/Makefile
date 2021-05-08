all : main.o addarrays.o
	g++ -o addarrays main.o addarrays.o
	strip -s addarrays

debug: main.o addarrays.o
	g++ -o addarrays main.o addarrays.o

addarrays.o : asm/addarrays.asm
	nasm -felf64 -g -Fdwarf -o addarrays.o addarrays.asm

main.o: main.cpp	
	g++ -g -c -pipe -no-pie -O2 -std=gnu++1z -Wall -Wextra -fPIC -o main.o main.cpp

clean:
	rm -f main.o addarrays.o addarrays