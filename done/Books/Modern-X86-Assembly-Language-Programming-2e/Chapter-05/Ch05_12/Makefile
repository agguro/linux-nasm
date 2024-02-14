name=ch05_12
asmfile=cc4
cppfile=main
libs=-lm

$(name):$(asmfile).o $(cppfile).o
	g++ -no-pie -o $(name) $(asmfile).o $(cppfile).o $(libs)
$(asmfile).o:$(asmfile).asm
	nasm -f elf64 -g -F dwarf -o $(asmfile).o $(asmfile).asm -l $(asmfile).lst
$(cppfile).o:$(cppfile).cpp
	g++ -c -pipe -o $(cppfile).o $(cppfile).cpp
clean:
	@rm -rf $(name) *.o *.lst
