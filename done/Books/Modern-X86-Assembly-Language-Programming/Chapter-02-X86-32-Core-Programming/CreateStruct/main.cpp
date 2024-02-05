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

extern "C" TestStruct* CreateTestStruct(int8_t val8, int16_t val16, int32_t val32, int64_t val64);
extern "C" void ReleaseTestStruct(TestStruct* p);

void PrintTestStruct(const char* msg, const TestStruct* ts)
{
	printf("%s\n", msg);
	printf("  ts->Val8:   %d\n", ts->Val8);
	printf("  ts->Val16:  %d\n", ts->Val16);
	printf("  ts->Val32:  %d\n", ts->Val32);
	printf("  ts->Val64:  %lld\n", ts->Val64);
}

int main(int argc, char* argv[])
{
	TestStruct* ts = CreateTestStruct(40, -401, 400002, -4000000003LL);
	
	PrintTestStruct("Contents of TestStruct 'ts'", ts);
	
	ReleaseTestStruct(ts);
	return 0;
}
