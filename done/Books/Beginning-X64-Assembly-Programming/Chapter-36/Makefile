name=matrix4x4

$(name): $(name).o
	gcc -o $(name) $(name).o -no-pie
$(name).o:$(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
clean:
	@rm -f $(name) *.o *.lst
