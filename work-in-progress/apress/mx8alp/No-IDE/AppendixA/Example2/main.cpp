/*
g++ -m32 -c main.cpp -o main.o
nasm -f elf32 -o example2.o example2.asm
g++ -m32 -o example2 example2.o main.o
*/

#include "stdio.h"

extern "C" void calcresult2(int a, int b, int c, int* quo, int* rem);

int main(int argc, char* argv[])
{
    int a = 75;
    int b = 125;
    int c = 7;
    int quo, rem;

    calcresult2(a, b, c, &quo, &rem);

    printf("a:   %4d  b:   %4d  c: %4d\n", a, b, c);
    printf("quo: %4d  rem: %4d\n", quo, rem);
    return 0;
}
