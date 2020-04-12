// semester test program
// gcc -o semester semester.c semester.o

#include <stdio.h>

extern int semester(int monthnumber);

int main()
{
    for(int i=1;i<13;i++)
    {
        printf ("monthnr %d is in semester %d.\n",i,semester(i));
    }
}
