NAME=downloadfile
AS=nasm
LD=ld
O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst

ASFLAGS     = -felf64
LDFLAGS     = -s -melf_x86_64
# change directories to the web root and cgi root on your system
WEBROOT     = ~/Http/public/cgi-demos/
CGIROOT     = ~/Http/bin/
BROWSER     = /usr/bin/firefox

OBJS = $(NAME)$(O)

.PHONY: again
.PHONY: debug
.PHONY: clean
.PHONY: install
.PHONY: test

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)
again:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME)
debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME)
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)

# here it is assumed that /js/jquery-min.js exists in the webroot	
install:
	$(MAKE) clean
	$(MAKE)
	-mkdir $(CGIROOT)downloads
	cp downloads/logo.png $(CGIROOT)downloads
	cp $(NAME).html $(WEBROOT)
	cp $(NAME) $(CGIROOT)
	
test:
	$(BROWSER) http://localhost/cgi-demos/$(NAME).html