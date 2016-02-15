LIBNAME=libfilemanager
LIBS=

#-lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lmysqlclient -R .

O = .o
SO = .so
LST = .lst
ASM = .asm
ASFLAGS= -felf64 -g
LDFLAGS=-s -melf_x86_64

$(LIBNAME)$(SO) : $(LIBNAME)$(O) 
	ld -shared -o $(LIBNAME)$(SO) $(LIBNAME)$(O) $(LIBS)
	
$(LIBNAME)$(O) : $(LIBNAME)$(ASM)
	nasm $(ASFLAGS) -o $(LIBNAME)$(O) $(LIBNAME)$(ASM) -l $(LIBNAME)$(LST)
		
again:
	touch $(LIBNAME)$(ASM)
	make
clean:
	rm -f *.out.* *$(O) $(LIBNAME)$(SO) *$(LST)
