// trimester test program
// gcc -o trimester trimester.c trimester.o

#include <stdio.h>

extern int trimester(int monthnumber);

int main()
{
    for(int i=1;i<13;i++)
    {
        printf ("monthnr %d is in trimester %d.\n",i,trimester(i));
    }
}
