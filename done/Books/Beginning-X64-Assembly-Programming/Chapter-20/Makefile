name=file

$(name): $(name).o
	gcc -o $(name) $(name).o -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf *.asm -l *.lst
clean:
	@rm $(name) *.o *.lst
