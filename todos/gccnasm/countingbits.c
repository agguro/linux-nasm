// example of passing parameters to assembler program from gcc

#include <stdio.h>

char* NumberOfLeadingZeros(char*,long long int,long long int,long long int,long long int,long long int, double);
int Array(int*,int);
void Execute(void(*)());


void procedure(){
    printf("%s \n", (char*)"procedure executed");
}

int main() {
    char* tekst;
    tekst = NumberOfLeadingZeros((char*)"this text you will see",(long long int)100,(long long int)100,(long long int)100,(long long int)100,(long long int)100,(double)10.5);
    printf("%s \n", tekst);
    int list[10] = { 0, 1, 2, 3, 5, 2, 3, 4, 0, 1 };
    int b = Array(list,4); //fifth item in array
    printf("%d \n", b);
    Execute(procedure);
}


