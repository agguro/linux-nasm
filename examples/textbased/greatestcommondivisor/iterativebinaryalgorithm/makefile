obj =gcdmain.o gcd.o hextodec.o

init:$(obj) makefile
	ld -o gcd $(obj)
	
gcd.o:gcd.asm
	nasm -felf64 gcd.asm

hextodec.o:hextodec.asm
	nasm -felf64 hextodec.asm
	
gcdmain.o:gcdmain.asm
	nasm -felf64 gcdmain.asm
