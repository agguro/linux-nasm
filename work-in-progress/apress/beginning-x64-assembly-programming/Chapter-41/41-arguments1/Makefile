name=arguments1

$(name): $(name).o
	gcc -no-pie -g -o $(name) $(name).o 
$(name).o: $(name).asm
	nasm -f elf64 -g -F Dwarf $(name).asm -l $(name).lst -o $(name).o
clean:
	@rm -f $(name) *.o *.lst
