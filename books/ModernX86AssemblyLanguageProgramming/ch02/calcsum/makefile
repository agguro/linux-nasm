NAME=calcsum

$(NAME): main.o $(NAME).o
	gcc -o $(NAME) $(NAME).o main.o
$(NAME).o: $(NAME).asm
	nasm -f elf64 -o $(NAME).o $(NAME).asm
main.o: main.cpp
	gcc -c main.cpp -o main.o
clean:
	rm $(NAME) *.o
