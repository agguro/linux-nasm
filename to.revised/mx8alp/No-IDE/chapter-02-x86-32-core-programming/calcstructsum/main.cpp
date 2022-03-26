#include <stdio.h>
#include <stdint.h>

typedef struct
{
	int8_t  Val8;
	int8_t  Pad8;
	int16_t Val16;
	int32_t Val32;
	int64_t Val64;
} TestStruct;

extern "C" int64_t CalcStructSum(const TestStruct* ts);

int64_t CalcStructSumCpp(const TestStruct* ts)
{
	return ts->Val8 + ts->Val16 + ts->Val32 + ts->Val64;
}

int main(int argc, char* argv[])
{
	TestStruct ts;
	
	ts.Val8 = -100;
	ts.Val16 = 2000;
	ts.Val32 = -300000;
	ts.Val64 = 40000000000;
	
	int64_t sum1 = CalcStructSumCpp(&ts);
	int64_t sum2 = CalcStructSum(&ts);
	
	printf("Input: %d  %d  %d  %lld\n", ts.Val8, ts.Val16, ts.Val32, ts.Val64);
	printf("sum1:  %lld\n", sum1);
	printf("sum2:  %lld\n", sum2);
	
	if (sum1 != sum2)
		printf("Sum verify check failed!\n");
	
	return 0;
}
