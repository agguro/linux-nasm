#include <stdio.h>
#include "../../commonfiles/xmmval.h"
#include "../../commonfiles/ymmval.h"
#include <memory.h>
#define _USE_MATH_DEFINES
#include <math.h>

// The order of values in the following enum must match the table
// that's defined in AvxBroadcast_.asm.
enum Brop : unsigned int
{
    Byte, Word, Dword, Qword
};

extern "C" void AvxBroadcastIntegerYmm(YmmVal* des, const XmmVal* src, Brop op);
extern "C" void AvxBroadcastFloat(YmmVal* des, float val);
extern "C" void AvxBroadcastDouble(YmmVal* des, double val);

void AvxBroadcastInteger(void)
{
    char buff[512];
    __attribute__((aligned(16))) XmmVal src;
	__attribute__((aligned(32))) YmmVal des;

    memset(&src, 0, sizeof(XmmVal));

    src.i16[0] = 42;
    AvxBroadcastIntegerYmm(&des, &src, Brop::Word);

    printf("\nResults for AvxBroadcastInteger() - Brop::Word\n");
    printf("src:   %s\n", src.ToString_i16(buff, sizeof(buff)));
    printf("des lo %s\n", des.ToString_i16(buff, sizeof(buff), false));
    printf("des hi %s\n", des.ToString_i16(buff, sizeof(buff), true));

    src.i64[0] = -80;
    AvxBroadcastIntegerYmm(&des, &src, Brop::Qword);

    printf("\nResults for AvxBroadcastInteger() - Brop::Qword\n");
    printf("src:    %s\n", src.ToString_i64(buff, sizeof(buff)));
    printf("des lo: %s\n", des.ToString_i64(buff, sizeof(buff), false));
    printf("des hi: %s\n", des.ToString_i64(buff, sizeof(buff), true));
}

void AvxBroadcastFloatingPoint(void)
{
    char buff[512];
	__attribute__((aligned(32))) YmmVal des;

    AvxBroadcastFloat(&des, (float)M_SQRT2);
    printf("\nResults for AvxBroadcastFloatingPoint() - float\n");
    printf("des lo: %s\n", des.ToString_r32(buff, sizeof(buff), false));
    printf("des hi: %s\n", des.ToString_r32(buff, sizeof(buff), true));

    AvxBroadcastDouble(&des, M_PI);
    printf("\nResults for AvxBroadcastFloatingPoint() - double\n");
    printf("des lo: %s\n", des.ToString_r64(buff, sizeof(buff), false));
    printf("des hi: %s\n", des.ToString_r64(buff, sizeof(buff), true));
}

int main(int argc, char* argv[])
{
    AvxBroadcastInteger();
    AvxBroadcastFloatingPoint();
    return 0;
}
