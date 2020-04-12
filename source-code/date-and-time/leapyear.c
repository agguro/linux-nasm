// leapyear test program
// gcc -o leapyear leapyear.c leapyear.o

#include <stdio.h>

extern int leapyear(unsigned int year);

int main()
{
    for (unsigned int i = 0;i < 3000;i=i+100){
        printf(" %d - %d \n",i,leapyear(i));
    }
}
