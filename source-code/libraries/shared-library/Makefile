.PHONY: all
.PHONY: clean
.PHONY: debug

LIBNAME=sharedlib
LIBS=-lc `pkg-config --libs gtk+-3.0`
VERSION=1.0
O = .o
SO = .so
LST = .lst
ASM = .asm
ASFLAGS= -felf64
LDFLAGS=-s -melf_x86_64
DEV=-dev
SONAME=$(LIBNAME)$(SO).1

$(LIBNAME)$(SO) : $(LIBNAME)$(O) 
	ld $(LIBS) --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname $(SONAME) -o $(LIBNAME)$(SO).$(VERSION) $(LIBNAME)$(O) -R .
	ln -sf $(LIBNAME)$(SO).$(VERSION) $(LIBNAME)$(SO).1

$(LIBNAME)$(O) : $(LIBNAME)$(ASM)
	nasm $(ASFLAGS) -o $(LIBNAME)$(O) $(LIBNAME)$(ASM)
	
$(LIBNAME)$(DEV)$(SO) : $(LIBNAME)$(DEV)$(O) 
	ld $(LIBS) --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname $(SONAME) -o $(LIBNAME)$(DEV)$(SO).$(VERSION) $(LIBNAME)$(DEV)$(O) -R .
	ln -sf $(LIBNAME)$(DEV)$(SO).$(VERSION) $(LIBNAME)$(SO).1

$(LIBNAME)$(DEV)$(O) : $(LIBNAME)$(ASM)
	nasm $(ASFLAGS) -o $(LIBNAME)$(DEV)$(O) -l $(LIBNAME)$(LST) $(LIBNAME)$(ASM)

all:
	$(MAKE) release
	$(MAKE) debug

release:
	$(MAKE) $(LIBNAME)$(SO) ASFLAGS="-felf64" LDFLAGS="-melf_x86_64"

debug:
	$(MAKE) $(LIBNAME)$(DEV)$(SO) ASFLAGS="-felf64 -Fdwarf -g" LDFLAGS="-g -melf_x86_64"
	
clean:
	rm -f *$(O) $(LIBNAME)$(SO) $(LIBNAME)$(DEV)$(SO) $(LIBNAME)$(SO).$(VERSION) $(LIBNAME)$(DEV)$(SO).$(VERSION) *$(LST) $(SONAME)
