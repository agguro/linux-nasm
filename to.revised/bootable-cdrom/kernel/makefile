NAME=kernel
TARGET=bin
AS=nasm

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst

OBJS = $(NAME)$(O)

$(NAME).o : $(NAME)$(ASM)
	mkdir -p ../cdrom
	$(AS) -f $(TARGET) -o ../cdrom/$(NAME).$(TARGET) $(NAME)$(ASM) -l $(NAME)$(LST)