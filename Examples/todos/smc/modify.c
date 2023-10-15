#include "stdio.h"

// assembly function f4
extern int f4();

int main(void) {
    int i;
    for(i=0;i<6;++i) {
        printf("%d\n",f4());
    }
    return 0;
}