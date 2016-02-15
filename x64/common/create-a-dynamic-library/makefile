.PHONY: all
.PHONY: clean
.PHONY: debug
.PHONY: again

NAME=hello
LIBNAME=libhello
LIBS=-lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 "$(LIBNAME).so" -R .
VERSION=1.0
O = .o
SO = .so
LST = .lst
ASM = .asm
ASFLAGS= -felf64
LDFLAGS=-s -melf_x86_64

$(NAME) : $(NAME)$(O) $(LIBNAME)$(SO)
	ld $(LDFLAGS) $(NAME)$(O) -o $(NAME) $(LIBS)
	
$(LIBNAME)$(SO) : $(LIBNAME)$(O) 
	ld -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -shared -soname $(LIBNAME)$(SO) -o $(LIBNAME)$(SO).$(VERSION) $(LIBNAME)$(O)
	@rm -f $(LIBNAME)$(SO)
	@ln -sf $(LIBNAME)$(SO).$(VERSION) $(LIBNAME)$(SO)
	
$(LIBNAME)$(O) : $(LIBNAME)$(ASM)
	nasm $(ASFLAGS) -o $(LIBNAME)$(O) $(LIBNAME)$(ASM) -l $(LIBNAME)$(LST)
	
$(NAME)$(O)  : $(NAME)$(ASM)
	nasm $(ASFLAGS) -o $(NAME)$(O) $(NAME)$(ASM) -l $(NAME)$(LST)
	
all:
	make clean
	make
	
debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME)
	
again:
	touch $(NAME)$(ASM)
	touch $(LIBNAME)$(ASM)
	make
	
clean:
	@rm -f *.out.* *$(O) $(NAME) $(LIBNAME)$(SO) $(LIBNAME)$(SO).$(VERSION) *$(LST)