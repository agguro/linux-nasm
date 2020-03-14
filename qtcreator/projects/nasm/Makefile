.phony: clean
.phony: release
.phony: debug

NAME= %{FileName}

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64 -no-pie
LIBS 	    = 
OBJS	    = 

$(NAME): $(NAME)$(O)
	ld $(LDFLAGS) $(NAME)$(O) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM)
	nasm $(ASFLAGS) $(NAME)$(ASM) -o $(NAME)$(O)

release:
	make clean
	make $(NAME)

debug:
	make clean
	make $(NAME) ASFLAGS="-felf64 -Fdwarf -g -l $(NAME)$(LST)" LDFLAGS="-g -melf_x86_64"

clean:
	@rm -f $(NAME) $(NAME)$(LST) $(NAME)$(O)
