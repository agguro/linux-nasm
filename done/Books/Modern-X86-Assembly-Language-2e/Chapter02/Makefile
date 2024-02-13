name=ch02_01
asmfile=integeraddsub
cppfile=main

$(name):$(asmfile).o $(cppfile).o
	g++ -Wl,-O1 -s -no-pie -o $(name) $(asmfile).o $(cppfile).o -lpthread
global.o:global.asm
	nasm -f elf64 -g -F dwarf -o $(asmfile).o $(asmfile).asm -l $(asmfile).lst
main.o:main.cpp
	g++ -c -pipe -O2 -Wall -Wextra -D_REENTRANT -fPIC -o $(cppfile).o $(cppfile).cpp
clean:
	@rm -rf $(name) *.o *.lst
