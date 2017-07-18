NAME=mysqlclientinfo
AS=nasm
LD=ld

.PHONY: nocgi
.PHONY: debug
.PHONY: clean

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst

OBJS        = $(NAME)$(O)
LIBS        = -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lmysqlclient

ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)

debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME)
	valgrind -v ./$(NAME)
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)
