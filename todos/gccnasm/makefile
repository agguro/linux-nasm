countingbits:	libbits.a countingbits.c
	gcc countingbits.c libbits.a -o countingbits

libbits.a:	libbits.o
	ar rcs libbits.a libbits.o
	
libbits.o:	libbits.asm
	nasm -f elf64 -o libbits.o libbits.asm -l libbits.lst


# nasm -f elf64 -o libbits.o libbits.asm -l libbits.lst
# ar rcs libbits.a libbits.o
# gcc countingbits.c libbits.a -o countingbits
