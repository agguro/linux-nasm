.PHONY : clean
.PHONY : again

file=screen
target=elf64

$(file) : $(file).o
	ld -s $(file).o -o $(file) -lc --dynamic-linker /usr/lib/x86_64-linux-gnu/libSDL-1.2.so.0
$(file).o : $(file).asm $(file).inc
	nasm -f $(target) -o $(file).o $(file).asm -l $(file).list
clean:
	rm -f *.o *~ *.list *.dump $(file) *.out.*
again:
	touch $(file).asm
	make