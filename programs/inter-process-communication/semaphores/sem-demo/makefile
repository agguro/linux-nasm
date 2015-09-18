files = semrm 
#semdemo

%: %.asm 
	make $@

all: 
	make clean
	make semrm
	make semdemo

clean:
	rm -f $(files) *.lst *.o
debug:
	make clean
	nasm -felf64 -Fstabs -g -o semrm.o -l semrm.lst semrm.asm
	nasm -felf64 -Fstabs -g -o semdemo.o -l semdemo.lst semdemo.asm
	ld -g -melf_x86_64 semrm.o -o semrm
	ld -g -melf_x86_64 semdemo.o -o semdemo

semrm: semrm.asm 
	nasm -felf64 -o semrm.o -l semrm.lst semrm.asm
	ld -s -m elf_x86_64 semrm.o -o semrm

semdemo: semdemo.asm 
	nasm -felf64 -o semdemo.o -l semdemo.lst semdemo.asm
	ld -s -m elf_x86_64 semdemo.o -o semdemo