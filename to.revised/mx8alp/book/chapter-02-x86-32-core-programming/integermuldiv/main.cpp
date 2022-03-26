#include <stdio.h>

extern "C" int IntegerMulDiv(int a, int b, int* prod, int* quo, int* rem);

int main(int argc, char *argv[])
{
    int a = 21, b = 9;
    int prod = 0, quo = 0, rem = 0;
    int rc;
    
    rc = IntegerMulDiv(a, b, &prod, &quo, &rem);
    printf(" Input1 - a:   %4d  b:    %4d\n", a, b);
    printf("Output1 - rc:  %4d  prod: %4d\n", rc, prod);
    printf("          quo: %4d  rem:  %4d\n\n", quo, rem);
    
    a = -29;
    prod = quo = rem = 0;
    rc = IntegerMulDiv(a, b, &prod, &quo, &rem);
    printf(" Input2 - a:   %4d  b:    %4d\n", a, b);
    printf("Output2 - rc:  %4d  prod: %4d\n", rc, prod);
    printf("          quo: %4d  rem:  %4d\n\n", quo, rem);
    
    b = 0;
    prod = quo = rem = 0;
    rc = IntegerMulDiv(a, b, &prod, &quo, &rem);
    printf(" Input3 - a:   %4d  b:    %4d\n", a, b);
    printf("Output3 - rc:  %4d  prod: %4d\n", rc, prod);
    printf("          quo: %4d  rem:  %4d\n\n", quo, rem);
    return 0;
    
}
