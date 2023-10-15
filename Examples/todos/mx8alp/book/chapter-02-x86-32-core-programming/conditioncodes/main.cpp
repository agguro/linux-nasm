#include <stdio.h>

extern "C" int SignedMinA(int a, int b, int c);
extern "C" int SignedMaxA(int a, int b, int c);
extern "C" int SignedMinB(int a, int b, int c);
extern "C" int SignedMaxB(int a, int b, int c);
extern "C" int SignedIsEQ(int a, int b);

int main(int argc, char* argv[])
{
	int a, b, c;
	int smin_a, smax_a;
	int smin_b, smax_b;
	
	// SignedMin examples
	a = 2; b = 15; c = 8;
	smin_a = SignedMinA(a, b, c);
	smin_b = SignedMinB(a, b, c);
	printf("SignedMinA(%4d, %4d, %4d) = %4d\n", a, b, c, smin_a);
	printf("SignedMinB(%4d, %4d, %4d) = %4d\n\n", a, b, c, smin_b);
	
	a = -3; b = -22; c = 28;
	smin_a = SignedMinA(a, b, c);
	smin_b = SignedMinB(a, b, c);
	printf("SignedMinA(%4d, %4d, %4d) = %4d\n", a, b, c, smin_a);
	printf("SignedMinB(%4d, %4d, %4d) = %4d\n\n", a, b, c, smin_b);
	
	a = 17; b = 37; c = -11;
	smin_a = SignedMinA(a, b, c);
	smin_b = SignedMinB(a, b, c);
	printf("SignedMinA(%4d, %4d, %4d) = %4d\n", a, b, c, smin_a);
	printf("SignedMinB(%4d, %4d, %4d) = %4d\n\n", a, b, c, smin_b);
	
	// SignedMax examples
	a = 10; b = 5; c = 3;
	smax_a = SignedMaxA(a, b, c);
	smax_b = SignedMaxB(a, b, c);
	printf("SignedMaxA(%4d, %4d, %4d) = %4d\n", a, b, c, smax_a);
	printf("SignedMaxB(%4d, %4d, %4d) = %4d\n\n", a, b, c, smax_b);
	
	a = -3; b = 28; c = 15;
	smax_a = SignedMaxA(a, b, c);
	smax_b = SignedMaxB(a, b, c);
	printf("SignedMaxA(%4d, %4d, %4d) = %4d\n", a, b, c, smax_a);
	printf("SignedMaxB(%4d, %4d, %4d) = %4d\n\n", a, b, c, smax_b);
	
	a = -25; b = -37; c = -17;
	smax_a = SignedMaxA(a, b, c);
	smax_b = SignedMaxB(a, b, c);
	printf("SignedMaxA(%4d, %4d, %4d) = %4d\n", a, b, c, smax_a);
	printf("SignedMaxB(%4d, %4d, %4d) = %4d\n\n", a, b, c, smax_b);
	
	//Signed is equal examples
	a = -25; b = -37;
	bool d = SignedIsEQ(a, b);
	if(d){printf("%4d = %d\n", a, b);}else{printf("%4d <> %d\n", a, b);}
	a = 25; b = 25;
	d = SignedIsEQ(a, b);
	if(d){printf("%4d = %d\n", a, b);}else{printf("%4d <> %d\n", a, b);}
}
