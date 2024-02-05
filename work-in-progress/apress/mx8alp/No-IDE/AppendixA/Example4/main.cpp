/*
g++ -m32 -c main.cpp -o main.o
nasm -f elf32 -o example4.o example4.asm
g++ -m32 -o example4 example4.o main.o
*/

#include "stdio.h"

extern "C" bool calcresult4(int* y, const int* x, int n);

int main(int argc, char* argv[])
{
    const int n = 8;
    const int x[n] = {3, 2, 5, 7, 8, 13, 20, 25};
    int y[n];

    bool error = calcresult4(y, x, n);

#if BITS == 32
    const char* sp = "x86";
#else
    const char* sp = "x64";
#endif

    printf("Results for solution platform %s\n\n", sp);
    if(!error){
        printf("     x      y\n");
        printf("--------------\n");

        for (int i = 0; i < n; i++)
            printf("%6d %6d\n", x[i], y[i]);
    }else{
        printf("there was an error\n");
    }
    return 0;
}
