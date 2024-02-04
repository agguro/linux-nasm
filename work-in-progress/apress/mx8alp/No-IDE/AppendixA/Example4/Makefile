NAME=example4

$(NAME): main.o $(NAME).o
	g++ -m32 -o $(NAME) $(NAME).o main.o
$(NAME).o: $(NAME).asm
	nasm -f elf32 -o $(NAME).o $(NAME).asm
main.o: main.cpp
	g++ -m32 -c main.cpp -o main.o
clean:
	rm $(NAME) *.o
