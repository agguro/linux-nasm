test: test.o bytebin2hexascii.o
	ld -melf_x86_64 -o test test.o bytebin2hexascii.o

bytebin2hexascii.o:bytebin2hexascii.asm
	/usr/bin/nasm -felf64 -Fdwarf -o bytebin2hexascii.o bytebin2hexascii.asm

test.o:test.asm
	/usr/bin/nasm -felf64 -Fdwarf -o test.o test.asm

.PHONY: clean
clean:
	rm -f test bytebin2hexascii *.o
