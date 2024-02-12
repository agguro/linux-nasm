# makefile for function4, circle and rect.
name=function4

$(name): $(name).o circle.o rect.o
	gcc -g -o $(name) $(name).o circle.o rect.o -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
circle.o: circle.asm
	nasm -f elf64 -g -F dwarf circle.asm -l circle.lst
rect.o: rect.asm
	nasm -f elf64 -g -F dwarf rect.asm -l rect.lst
clean:
	@rm -f $(name) *.o *.lst
