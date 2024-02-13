name=sse_string5

$(name): $(name).o print16b.o
	gcc -o $(name) $(name).o print16b.o -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
printrb: print16b.c 
	gcc -c print16b.c
clean:
	 @rm -f $(name) *.o *.lst
