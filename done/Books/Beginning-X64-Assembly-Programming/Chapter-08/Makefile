name=memory

$(name): $(name).o
	gcc -o $(name) $(name).o -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf -l $(name).lst $(name).asm
clean:
	@rm -rf $(name) *.o *.lst
