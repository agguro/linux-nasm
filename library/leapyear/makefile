.PHONY: all
.PHONY: debug
.PHONY: clean

NAME=leapyear
AS=nasm

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst

ASFLAGS     = "-felf64"

OBJS = $(NAME)$(O)

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)

all:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME)
debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g"
clean:
	@rm -f *.out.* $(NAME)$(LST) $(NAME)$(O)
