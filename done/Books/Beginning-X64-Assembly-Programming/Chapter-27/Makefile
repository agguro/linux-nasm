name=cpu_sse

$(name): $(name).o print_mxcsr.o print_hex.o
	gcc -o $(name) $(name).o print_mxcsr.o print_hex.o -no-pie
$(name).o: $(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
print_mxcsr: print_mxcsr.c
	gcc -c print_mxcsr.c 
print_hex: print_hex.c
	gcc -c print_hex.c
clean:
	rm -f $(name) *.o *.lst
