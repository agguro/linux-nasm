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
	cd static && make && cd ..
	cd shared && make && cd ..
	$(LD) $(SHAREDLIBS) --dynamic-linker /lib64/ld-linux-x86-64.so.2 $(LDFLAGS) -o $(NAME) $(OBJS) $(STATICLIBS) -R ./shared

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) $(LIST) -o $(NAME)$(O)

all:
	$(MAKE) debug
	$(MAKE) release

debug:
	cd static && make debug && cd ..
	cd shared && make debug && cd ..
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fdwarf" LDFLAGS="-g -melf_x86_64" LIST="-l $(NAME)$(LST)"

release:
	cd static && make release && cd ..
	cd shared && make release && cd ..
	$(MAKE) $(NAME) ASFLAGS="-felf64" LDFLAGS="-melf_x86_64"

clean:
	cd static && make clean && cd ..
	cd shared && make clean && cd ..
	rm -f $(NAME) $(NAME)$(LST) $(NAME)$(O)
