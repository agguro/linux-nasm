test: test.o bytebcd2ascii.o
	ld -melf_x86_64 -o test test.o bytebcd2ascii.o

bytebcd2ascii.o:bytebcd2ascii.asm
	/usr/bin/nasm -felf64 -Fdwarf -o bytebcd2ascii.o bytebcd2ascii.asm

test.o:test.asm
	/usr/bin/nasm -felf64 -Fdwarf -o test.o test.asm

.PHONY: clean
clean:
	rm -f gmon.out test bytebcd2ascii *.o
