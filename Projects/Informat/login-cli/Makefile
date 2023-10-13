## Makefile for informat project login-cli

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
OBJS	= stringsearch.o
INC     = login-cli.inc section.bss.inc section.rodata.inc section.data.inc

$(NAME): $(NAME)$(O) $(OBJS)
	ld $(LDFLAGS) -o $(NAME) $(NAME)$(O) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM) $(INC)
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
