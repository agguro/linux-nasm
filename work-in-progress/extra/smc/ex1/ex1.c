#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/mman.h>

char buffer [0x2000];
void* bufferp;

char* hola_mundo = "Hola mundo!";
int (*_printf)(const char*,...);

void hola()
{ 
    _printf(hola_mundo);
}

int main ( void )
{
    //Compute the start of the page
    bufferp = (void*)( ((unsigned long)buffer+0x1000) & 0xfffff000 );
    /*if(mprotect(bufferp, 1024, PROT_READ|PROT_EXEC|PROT_WRITE))
    {
        printf("mprotect failed\n");
        return(1);
    }*/
    //The printf function has to be called by an exact address
    _printf = printf;

    //Copy the function hola into buffer
    memcpy(bufferp,(void*)hola,60); //Arbitrary size);


    ((void (*)())bufferp)();  

    return(0);
}

