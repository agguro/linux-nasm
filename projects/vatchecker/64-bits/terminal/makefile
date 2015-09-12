NAME=vatchecker
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64
ARGS        = BE012345678
OBJS = $(NAME)$(O)

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)

production:
	@# without debugging symbols
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME)
	
all:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME)
	
development:
	@# with debugging symbols
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME) $(ARGS)
	valgrind -v ./$(NAME) $(ARGS)
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)