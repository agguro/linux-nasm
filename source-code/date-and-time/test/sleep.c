// sleep test program
// gcc -o sleep sleep.c sleep.o

#include <stdio.h>

extern void sleep(unsigned int seconds);

int main()
{
    unsigned int secs = 10;
    printf("sleeping %d seconds....\n",secs);
    sleep(secs);
    printf("awaken\n");
}
