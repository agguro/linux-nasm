.PHONY: all
.PHONY: debug
.PHONY: clean

NAME=bubblesort
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst

ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64

OBJS = $(NAME)$(O)

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM) optimizingstep0.asm optimizingstep1.asm optimizingstep2.asm
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)

all:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME)
debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME)
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)
