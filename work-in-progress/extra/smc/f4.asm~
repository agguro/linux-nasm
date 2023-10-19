;source: https://stackoverflow.com/questions/4812869/how-to-write-self-modifying-code-in-x86-assembly

#include <stdio.h>

 // assembly function f4
 extern int f4();
 
int main(void) {
    int i;
    
    for(i=0;i<6;++i) {
        printf("%d\n",f4());
    }
    return 0;
}
