/*
g++ -c main.cpp -o main.o
nasm -f elf64 -o example3.o example3.asm
g++ -o example3 example3.o main.o
*/

#include "stdio.h"

extern "C" double calcresult3(long long int a, long long int b, double c, double d);

int main(int argc, char* argv[])
{
    long long int a = 10;
    long long int b = -15;
    double c = 2.0;
    double d = -3.0;

    double e = calcresult3(a, b, c, d);

    printf("a: %lld  b: %lld  c: %.4lf  d: %.4lf\n", a, b, c, d);
    printf("e: %.4lf\n", e);

    return 0;
}
