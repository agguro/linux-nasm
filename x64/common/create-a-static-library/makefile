.PHONY: all
.PHONY: again
.PHONY: clean
.PHONY: debug

NAME=hello
LIBNAME=libhello
AS=nasm
LD=ld
AR          = ar
AROPT	    = rcs
O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
ARCH        = .a
ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64
#only for the library name
DEBUG       =				

OBJS = $(NAME)$(O)
LIBOBJS = $(LIBNAME)$(O)

$(NAME): $(OBJS) $(LIBNAME)$(ARCH)
	$(LD) $(LDFLAGS) -o $(NAME) $(OBJS) $(LIBNAME)$(ARCH)
	
$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -o $(NAME)$(O) -l $(NAME)$(LST)

$(LIBNAME)$(ARCH): $(LIBOBJS)
	@rm -f $(LIBNAME)$(DEBUG)$(ARCH)
	$(AR) $(AROPT) $(LIBNAME)$(DEBUG)$(ARCH) $(LIBNAME)$(O)

$(LIBNAME)$(O): $(LIBNAME)$(ASM)
	$(AS) $(ASFLAGS) $(LIBNAME)$(ASM) -l $(LIBNAME)$(LST) -o $(LIBNAME)$(O)

all:
	touch $(NAME)$(ASM)
	touch $(LIBNAME)$(ASM)
	$(MAKE) $(LIBNAME)$(DEBUG)$(ARCH)
	$(MAKE) $(NAME)
	touch $(LIBNAME)$(ASM)
	$(MAKE) $(LIBNAME)$(DEBUG)$(ARCH) DEBUG="-dev" ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64" AROPT="rcs"

debug:
	touch $(NAME)$(ASM)
	touch $(LIBNAME)$(ASM)
	$(MAKE) $(LIBNAME)$(DEBUG)$(ARCH) DEBUG="-dev" ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64" AROPT="rcs"
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME) > valgrind.out.txt
	
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O) $(LIBNAME)$(ARCH) $(LIBNAME)-dev$(ARCH) $(LIBNAME)$(LST) $(LIBNAME)$(O)