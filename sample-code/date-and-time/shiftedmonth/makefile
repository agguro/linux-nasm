NAME=shiftedmonth
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64

OBJS = $(NAME)$(O)

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)

debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"

clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)
