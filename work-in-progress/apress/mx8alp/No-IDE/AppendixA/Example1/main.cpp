#include "stdio.h"

extern "C" int calcresult1(int a, int b, int c);

int main(int argc, char* argv[])
{
    int a = 30;
    int b = 20;
    int c = 10;
    int d = calcresult1(a, b, c);

    printf("a: %4d  b: %4d  c: %4d\n", a, b, c);
    printf("d: %4d\n", d);
    return 0;
}
