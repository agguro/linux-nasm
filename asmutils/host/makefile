.PHONY: all
.PHONY: clean
.PHONY: debug

NAME=host
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst

ASFLAGS     = "-felf32"
LDFLAGS     = -s -melf_i386

OBJS = $(NAME)$(O)

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)
all:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME)
debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf32 -Fstabs -g" LDFLAGS="-g -melf_i386"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME)
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)
