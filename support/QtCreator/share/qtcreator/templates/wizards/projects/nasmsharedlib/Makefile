.PHONY: release
.PHONY: debug
.PHONY: clean

LIBNAME= %{FileName}

O		= .o
SO		= .so
ASM		= .asm
LST		= .lst
TXT		= .txt
ASFLAGS		= -felf64
LDFLAGS		= -s -melf_x86_64
VERSION		= 1.0.0
DEBUG		= 
CURRENTDIR	= $(shell pwd)

$(LIBNAME)$(SO) : $(LIBNAME)$(O) 
	ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname $(LIBNAME)$(SO) -o $(LIBNAME).$(VERSION)$(DEBUG)$(SO) $(LIBNAME)$(O) -rpath .
	@rm -f $(LIBNAME)$(SO)
	@ln -sf $(CURRENTDIR)/$(LIBNAME).$(VERSION)$(DEBUG)$(SO) $(LIBNAME)$(SO)
	
$(LIBNAME)$(O) : $(LIBNAME)$(ASM)
	nasm $(ASFLAGS) -o $(LIBNAME)$(O) $(LIBNAME)$(ASM)
	
release:
	make clean
	make $(LIBNAME)$(SO) ASFLAGS="-felf64" LDFLAGS="-s -melf_x86_64"
	objdump -T $(LIBNAME)$(SO) > export.txt	
debug:
	make clean
	make $(LIBNAME)$(DEBUG)$(SO) DEBUG="-dev" ASFLAGS="-felf64 -Fdwarf -g -l $(LIBNAME)$(LST)" LDFLAGS="-g -melf_x86_64"
	objdump -T $(LIBNAME)$(DEBUG)$(SO) > export.txt	
clean:
	rm -f  *$(O) *$(SO) *$(LST) *$(TXT)
