# makefile for alive.asm

name=alive

$(name): $(name).o
	gcc -o $(name) $(name).o -ggdb -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
#	yasm -f elf64 -g dwarf2 $(name).asm -l $(name).lst
clean:
	@rm -f $(name) *.o *.lst
