# makefile for bits1 and printb
name=bits1

$(name): $(name).o printb.o
	gcc -g -o $(name) printb.o $(name).o -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
printb: printb.c 
	gcc -c printb.c
clean:
	@rm -f $(name) *.o *.lst
