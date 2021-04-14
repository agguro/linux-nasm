NAME=libexample
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst

ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64
LIST        =
SHAREDLIBS  = shared/libshared.so
STATICLIBS  = static/libstatic.a

OBJS = $(NAME)$(O)

$(NAME): $(OBJS)
	$(LD) $(SHAREDLIBS) --dynamic-linker /lib64/ld-linux-x86-64.so.2 $(LDFLAGS) -o $(NAME) $(OBJS) $(STATICLIBS) -R .

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) $(LIST) -o $(NAME)$(O)

all:
	$(MAKE) debug
	$(MAKE) release
	
debug:
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fdwarf" LDFLAGS="-g -melf_x86_64" LIST="-l $(NAME)$(LST)"

release:
	$(MAKE) $(NAME) ASFLAGS="-felf64" LDFLAGS="-melf_x86_64"

clean:
	rm -f $(NAME) $(NAME)$(LST) $(NAME)$(O)
