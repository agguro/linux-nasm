name=ch05_12
asmfile=cc4
cppfile=main
libs=-lm

$(name):$(asmfile).o $(cppfile).o
	g++ -Wl,-O1 -s -no-pie -o $(name) $(asmfile).o $(cppfile).o -lpthread $(libs)
$(asmfile).o:$(asmfile).asm
	nasm -f elf64 -g -F dwarf -o $(asmfile).o $(asmfile).asm -l $(asmfile).lst
$(cppfile).o:$(cppfile).cpp
	g++ -c -pipe -O2 -Wall -Wextra -D_REENTRANT -fPIC -o $(cppfile).o $(cppfile).cpp
clean:
	@rm -rf $(name) *.o *.lst
