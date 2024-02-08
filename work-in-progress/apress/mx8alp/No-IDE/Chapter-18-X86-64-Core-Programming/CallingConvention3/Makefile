NAME=callingconvention3

$(NAME): main.o $(NAME).o
	g++ -no-pie -o $(NAME) $(NAME).o main.o
$(NAME).o: $(NAME).asm
	nasm -f elf64 -o $(NAME).o $(NAME).asm
main.o: main.cpp
	g++ -no-pie -c main.cpp -o main.o
clean:
	@rm -f $(NAME) *.o
