NAME=getallaccountsextended

NASM=/usr/bin/nasm
NASMOPTS=-felf64 -Fdwarf
LDOPS=-melf_x86_64 -g
DYN=--dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS=-lssl -lcrypto     #install sudo apt install libssl-dev

.PHONY: all clean

all: $(NAME)

clean:
	rm -f $(NAME)

$(NAME).o: $(NAME).asm 
	$(NASM) $(NASMOPTS) $(NAME).asm -o $(NAME).o

$(NAME): $(NAME).o
	$(LD) $(DYN) $(LDOPS) -o $(NAME) $(NAME).o $(LIBS)
