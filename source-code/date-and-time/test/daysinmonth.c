// daysinmonth test program
// gcc -o daysinmonth daysinmonth.c daysinmonth.o

#include <stdio.h>

extern int daysinmonth(int monthnumber);

int main()
{
    for(int i=1;i<13;i++)
    {
    printf ("monthnr %d has %d days.\n",i,daysinmonth(i));
    }
}
