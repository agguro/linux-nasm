// quadrimester test program
// gcc -o quadrimester quadrimester.c quadrimester.o

#include <stdio.h>

extern int quadrimester(int monthnumber);

int main()
{
    for(int i=1;i<13;i++)
    {
        printf ("monthnr %d is in quadrimester %d.\n",i,quadrimester(i));
    }
}
