.PHONY : clean
.PHONY : again

file=oop
target=elf64

$(file) : $(file).o
	ld -s $(file).o  -o $(file)
$(file).o : $(file).asm $(file).inc
	nasm -f $(target) -o $(file).o $(file).asm -l $(file).list
clean:
	rm -f *.o *~ *.list *.dump $(file) *.out.*
again:
	touch $(file).asm
	make
