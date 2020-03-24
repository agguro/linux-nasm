#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

typedef struct
{
	int8_t  Val8;
	int8_t  Pad8;
	int16_t Val16;
	int32_t Val32;
	int64_t Val64;
} TestStruct;

extern "C" TestStruct* CreateTestStruct_(int8_t val8, int16_t val16, int32_t val32, int64_t val64);
extern "C" void ReleaseTestStruct_(TestStruct* p);

void PrintTestStruct(const char* msg, const TestStruct* ts)
{
	printf("%s\n", msg);
	printf("  ts->Val8:   %" PRId8 "\n", ts->Val8);
	printf("  ts->Val16:  %" PRId16 "\n", ts->Val16);
	printf("  ts->Val32:  %" PRId32 "\n", ts->Val32);
	printf("  ts->Val64:  %" PRId64 "\n", ts->Val64);
}

int main()
{
	TestStruct* ts = CreateTestStruct_(40, -401, 400002, -4000000003LL);
	
	PrintTestStruct("Contents of TestStruct 'ts'", ts);
	
	ReleaseTestStruct_(ts);
	return 0;
}
