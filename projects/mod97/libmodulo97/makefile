.PHONY: clean

NAME=libmodulo97
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
A	    = .a

ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64

OBJS = $(NAME)$(O)

$(NAME).a: $(NAME)$(O)
	ar rcs $(NAME).a $(NAME)$(O)
	
$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)

clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O) $(NAME)$(A)

again:
	make clean
	touch $(NAME)$(ASM)
	$(MAKE)
