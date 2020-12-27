#include <stdio.h>

extern "C" bool isLeapYear(long int year);

int main(int argc, char *argv[])
{
	for(long int year = 2000;year <= 2100;year++){
		bool isLeap = isLeapYear(year);
		if(isLeap){
			printf("%ld : leapyear\n",year);
		}else{
			printf("%ld : not a leapyear\n",year);
		}
	}
    return 0;
}
