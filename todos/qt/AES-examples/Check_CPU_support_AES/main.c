//source: Intel(R) Advanced Encryption Standard - New Instructionset White Paper
//page 23...

#include <stdio.h>

#define cpuid(func,cx) __asm__ __volatile__ ("cpuid": "=c" (cx) : "a" (func) );

int Check_CPU_support_AES()
{
    unsigned int a;
    cpuid(1, a);
    return (a & 0x2000000);
}

int main()
{
    printf("CPU ID - CPU support AES: %x\n", Check_CPU_support_AES());
    return 0;
}
