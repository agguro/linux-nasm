.PHONY: all
.PHONY: clean

all: speak.o speak.asm tick.o tick.asm section.bss.inc
	make speak
	make tick

speak: speak.o
	ld -s -melf_x86_64 -o speak speak.o
	
speak.o: speak.asm section.bss.inc
	nasm -felf64 speak.asm -l speak.lst -o speak.o

tick: tick.o
	ld -s -melf_x86_64 -o tick tick.o
	
tick.o: tick.asm section.bss.inc
	nasm -felf64 tick.asm -l tick.lst -o tick.o
	
clean:
	@rm -f speak tick speak.lst tick.lst speak.o tick.o fifo-buffer