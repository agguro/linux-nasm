NAME=example4
BITS=64
BUILD=

$(NAME): main.o $(NAME).o
	g++ $(BUILD) -D BITS=$(BITS) -o $(NAME) $(NAME).o main.o
$(NAME).o: $(NAME).asm
	nasm -f elf$(BITS) -D BITS=$(BITS) -o $(NAME).o $(NAME).asm
main.o: main.cpp
	g++ $(BUILD) -D BITS=$(BITS) -c main.cpp -o main.o
	
64bits:
	@echo "building for 64 bits, to build 32 bits version use make 32bits."
	@echo "---------------------------------------------------------------"
	@touch $(NAME).asm main.cpp
	@$(MAKE) BITS=64 BUILD=
	
32bits:
	@echo "building for 32 bits, to build 64 bits version use make 64bits."
	@echo "---------------------------------------------------------------"
	@touch $(NAME).asm main.cpp
	@$(MAKE) BITS=32 BUILD=-m32
	
clean:
	rm $(NAME) *.o
