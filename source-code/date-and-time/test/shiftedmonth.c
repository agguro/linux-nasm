// shiftedmonth test program
// gcc -o shiftedmonth shiftedmonth.c shiftedmonth.o

#include <stdio.h>

extern int shiftedmonth(int monthnumber);

int main()
{
    for(int i=1;i<13;i++)
    {
    printf ("shifted month number of monthnr %d is %d.\n",i,shiftedmonth(i));
    }
}
