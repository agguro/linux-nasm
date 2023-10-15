#include "../../commonfiles/xmmval.h"
#define _USE_MATH_DEFINES
#include <math.h>

extern "C" void SsePackedFpMath32(const XmmVal* a, const XmmVal* b, XmmVal c[8]);
extern "C" void SsePackedFpMath64(const XmmVal* a, const XmmVal* b, XmmVal c[8]);

void SsePackedFpMath32Cpp(void)
{
	__attribute__ ((aligned(16))) XmmVal a;
	__attribute__ ((aligned(16))) XmmVal b;
	__attribute__ ((aligned(16))) XmmVal c[8];
    char buff[256];

    a.r32[0] = 36.0f;
    a.r32[1] = (float)(1.0 / 32.0);
    a.r32[2] = 2.0f;
    a.r32[3] = 42.0f;

    b.r32[0] = -(float)(1.0 / 9.0);
    b.r32[1] = 64.0f;
    b.r32[2] = -0.0625f;
    b.r32[3] = 8.666667f;

    SsePackedFpMath32(&a, &b, c);
    printf("\nResults for SsePackedFpMath32_\n");
    printf("a:         %s\n", a.ToString_r32(buff, sizeof(buff)));
    printf("b:         %s\n", b.ToString_r32(buff, sizeof(buff)));
    printf("\n");
    printf("addps:     %s\n", c[0].ToString_r32(buff, sizeof(buff)));
    printf("subps:     %s\n", c[1].ToString_r32(buff, sizeof(buff)));
    printf("mulps:     %s\n", c[2].ToString_r32(buff, sizeof(buff)));
    printf("divps:     %s\n", c[3].ToString_r32(buff, sizeof(buff)));
    printf("absps a:   %s\n", c[4].ToString_r32(buff, sizeof(buff)));
    printf("sqrtps a:  %s\n", c[5].ToString_r32(buff, sizeof(buff)));
    printf("minps:     %s\n", c[6].ToString_r32(buff, sizeof(buff)));
    printf("maxps:     %s\n", c[7].ToString_r32(buff, sizeof(buff)));
}

void SsePackedFpMath64Cpp(void)
{
	__attribute__ ((aligned(16))) XmmVal a;
	__attribute__ ((aligned(16))) XmmVal b;
	__attribute__ ((aligned(16))) XmmVal c[8];
    char buff[256];

    a.r64[0] = 2.0;
    a.r64[1] = M_PI;
    b.r64[0] = M_E;
    b.r64[1] = -M_1_PI;

    SsePackedFpMath64(&a, &b, c);
    printf("\nResults for SsePackedFpMath64_\n");
    printf("a:         %s\n", a.ToString_r64(buff, sizeof(buff)));
    printf("b:         %s\n", b.ToString_r64(buff, sizeof(buff)));
    printf("\n");
    printf("addpd:     %s\n", c[0].ToString_r64(buff, sizeof(buff)));
    printf("subpd:     %s\n", c[1].ToString_r64(buff, sizeof(buff)));
    printf("mulpd:     %s\n", c[2].ToString_r64(buff, sizeof(buff)));
    printf("divpd:     %s\n", c[3].ToString_r64(buff, sizeof(buff)));
    printf("abspd a:   %s\n", c[4].ToString_r64(buff, sizeof(buff)));
    printf("sqrtpd a:  %s\n", c[5].ToString_r64(buff, sizeof(buff)));
    printf("minpd:     %s\n", c[6].ToString_r64(buff, sizeof(buff)));
    printf("maxpd:     %s\n", c[7].ToString_r64(buff, sizeof(buff)));
}

int main(int argc, char* argv[])
{
    SsePackedFpMath32Cpp();
    SsePackedFpMath64Cpp();
}
