name=aligned

$(name): $(name).o
	gcc -g -o $(name) $(name).o -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
clean:
	@rm -f $(name) *.o *.lst
