.PHONY: clean

LIBNAME=staticlib
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
DEV         = -dev

OBJS = $(NAME)$(O)

$(LIBNAME)$(ARCH): $(LIBNAME)$(O)
	$(AR) $(AROPT) $(LIBNAME)$(ARCH) $(LIBNAME)$(O)

$(LIBNAME)$(O): $(LIBNAME)$(ASM)
	$(AS) $(ASFLAGS) $(LIBNAME)$(ASM) -o $(LIBNAME)$(O)

$(LIBNAME)$(DEV)$(ARCH): $(LIBNAME)$(DEV)$(O)
	$(AR) $(AROPT) $(LIBNAME)$(DEV)$(ARCH) $(LIBNAME)$(DEV)$(O)

$(LIBNAME)$(DEV)$(O): $(LIBNAME)$(ASM)
	$(AS) $(ASFLAGS) $(LIBNAME)$(ASM) -l $(LIBNAME)$(DEV)$(LST) -o $(LIBNAME)$(DEV)$(O)

all:
	$(MAKE) release
	$(MAKE) debug

release:
	$(MAKE) $(LIBNAME)$(ARCH) ASFLAGS="-felf64" LDFLAGS="-melf_x86_64" AROPT="rcs"

debug:
	$(MAKE) $(LIBNAME)$(DEV)$(ARCH) DEV="-dev" ASFLAGS="-felf64 -Fdwarf -g" LDFLAGS="-g -melf_x86_64" AROPT="rcs"

clean:
	rm -f $(LIBNAME)$(ARCH) $(LIBNAME)$(DEV)$(ARCH) $(LIBNAME)$(LST) $(LIBNAME)$(O) $(LIBNAME)$(DEV)$(O) *$(LST)
