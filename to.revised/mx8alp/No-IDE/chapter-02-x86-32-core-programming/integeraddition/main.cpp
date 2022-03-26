#include <stdio.h>

char GlChar = 10;
short GlShort = 20;
int GlInt = 30;
long long GlLongLong = 0x000000000FFFFFFFE;

extern char GlChar;
extern short GlShort;
extern int GlInt;
extern long long GlLongLong;

extern "C" void IntegerAddition(char a, short b, int c, long long d);

int main(int argc, char* argv[])
{
	printf("Before GlChar:     %d\n", GlChar);
	printf("       GlShort:    %d\n", GlShort);
	printf("       GlInt:      %d\n", GlInt);
	printf("       GlLongLong: %lld\n", GlLongLong);
	printf("\n");
	
	IntegerAddition(3, 5, -37, 11);
	
	printf("After  GlChar:     %d\n", GlChar);
	printf("       GlShort:    %d\n", GlShort);
	printf("       GlInt:      %d\n", GlInt);
	printf("       GlLongLong: %lld\n", GlLongLong);
	return 0;
}
