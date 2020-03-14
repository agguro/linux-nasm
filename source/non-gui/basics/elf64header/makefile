NAME = elf64header
TARGET = bin
BIN = .bin
ASM = .asm
AS = nasm
LST = .lst

$(NAME)$(BIN) : $(NAME)$(ASM)
	$(AS) -f $(TARGET) -o $(NAME) $(NAME)$(ASM) -l $(NAME)$(LST)
	chmod +x $(NAME)
clean:
	rm -f *~ *$(LST) *.dump $(NAME)
again:
	touch $(NAME).asm
	make
dump:
	make again
	hexdump -C $(NAME) > $(NAME).dump