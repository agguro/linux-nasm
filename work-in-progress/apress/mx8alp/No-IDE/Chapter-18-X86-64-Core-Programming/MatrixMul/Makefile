NAME=matrixmul

$(NAME): main.o $(NAME).o
	g++ -g -o $(NAME) $(NAME).o main.o
$(NAME).o: $(NAME).asm
	nasm -f elf64 -o $(NAME).o $(NAME).asm
main.o: main.cpp
	g++ -g -c main.cpp -o main.o
clean:
	@rm -f $(NAME) *.o
