.PHONY : clean
.PHONY : again

file=pem1asm
target=elf64

$(file) : $(file).o
	ld -s $(file).o  -o $(file)
$(file).o : $(file).asm
	nasm -f $(target) -o $(file).o $(file).asm -l $(file).list
clean:
	rm -f *.o *~ *.list $(file)
again:
	touch $(file).asm
	make
