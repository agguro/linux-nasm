test: test.o twordhex2bcd.o
	ld -melf_x86_64 -o test test.o twordhex2bcd.o

twordhex2bcd.o:twordhex2bcd.asm
	/usr/bin/nasm -felf64 -Fdwarf -o twordhex2bcd.o twordhex2bcd.asm

test.o:test.asm
	/usr/bin/nasm -felf64 -Fdwarf -o test.o test.asm

.PHONY: clean
clean:
	rm -f gmon.out test *.o
