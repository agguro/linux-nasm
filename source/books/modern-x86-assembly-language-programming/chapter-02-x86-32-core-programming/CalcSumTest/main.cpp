#include <stdio.h>

extern "C" int CalcSum_(int a, int b, int c);

int main()
{
    int a=17, b=11, c=14;
    int sum = CalcSum_(a,b,c);
    printf("  a:   %d\n", a);
    printf("  b:   %d\n", b);
    printf("  c:   %d\n", c);
    printf("  sum: %d\n", sum);
    return 0;
}
