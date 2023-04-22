##Makefile for informat login project

.phony: clean
.phony: release
.phony: debug

NAME= login-cli

O	= .o
ASM	= .asm
INC	= .inc
LST	= .lst
ASFLAGS	= "-felf64"
LDFLAGS	= -s -melf_x86_64 -no-pie
LIBS	=
OBJS	=  stringsearch.o

$(NAME): $(NAME)$(O) $(OBJS)
	ld $(LDFLAGS) $(NAME)$(O) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM)
	nasm $(ASFLAGS) $(NAME)$(ASM) -o $(NAME)$(O)

stringsearch.o:stringsearch.asm
	nasm $(ASFLAGS) stringsearch.asm -o stringsearch.o

release:
	make clean
	make $(NAME)

debug:
	make clean
	make $(NAME) ASFLAGS="-felf64 -Fdwarf -g -l $(NAME)$(LST) -DDEBUG" LDFLAGS="-g -melf_x86_64"

clean:
	@rm -f $(NAME) $(NAME)$(LST) $(NAME)$(O)
