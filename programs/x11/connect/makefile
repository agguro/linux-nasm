NAME=connect
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64

OBJS = $(NAME)$(O)
LIBS=-lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lX11
# -L/usr/X11R6/lib in case of problems try to add this behind previous line

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
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME)
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)