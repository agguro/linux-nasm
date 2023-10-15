test: test.o fpuhex2bcd.o
	ld -melf_x86_64 -o test test.o fpuhex2bcd.o

fpuhex2bcd.o:fpuhex2bcd.asm
	/usr/bin/nasm -felf64 -Fdwarf -o fpuhex2bcd.o fpuhex2bcd.asm

test.o:test.asm
	/usr/bin/nasm -felf64 -Fdwarf -o test.o test.asm

.PHONY: clean
clean:
	rm -f gmon.out test fpuhex2bcd *.o
