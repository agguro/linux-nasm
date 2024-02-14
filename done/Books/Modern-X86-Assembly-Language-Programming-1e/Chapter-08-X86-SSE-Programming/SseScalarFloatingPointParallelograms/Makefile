NAME=ssescalarfloatingpointparallelograms

$(NAME): main.o $(NAME).o
	g++ -no-pie -m32 -o $(NAME) $(NAME).o main.o

$(NAME).o: $(NAME).asm
	nasm -f elf32 -o $(NAME).o $(NAME).asm

main.o: main.cpp
	g++ -c -no-pie -m32 main.cpp -o main.o -std=c++11
clean:
	@rm -f $(NAME) *.o
