#include <stdio.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include "../../CommonFiles/miscdefs.h"

// Simple union for data exchange
union XmmScalar
{
    float r32;
    double r64;
    Uint32 i32;
    Uint64 i64;
};

// The order of values below must match the jump table
// that's defined in SseScalarFloatingPointConversions_.asm.
enum CvtOp : unsigned int
{
    Cvtsi2ss,       // Int32 to float
    Cvtss2si,       // float to Int32
    Cvtsi2sd,       // Int32 to double
    Cvtsd2si,       // double to Int32
    Cvtss2sd,       // float to double
    Cvtsd2ss,       // double to float
};

// Enumerated type for x86-SSE rounding mode
enum SseRm : unsigned int
{
    Nearest, Down, Up, Truncate
};

extern "C" Uint32 SseGetMxcsr(void);
extern "C" Uint32 SseSetMxcsr(Uint32 mxcsr);

extern "C" SseRm SseGetMxcsrRoundingMode(void);
extern "C" void SseSetMxcsrRoundingMode(SseRm rm);
extern "C" bool SseSfpConversion(XmmScalar* a, XmmScalar* b, CvtOp cvt_op);

const SseRm SseRmVals[] = {SseRm::Nearest, SseRm::Down, SseRm::Up, SseRm::Truncate};
const char* SseRmStrings[] = {"Nearest", "Down", "Up", "Truncate"};

void SseSfpConversions(void)
{
    XmmScalar src1, src2;
    XmmScalar des1, des2;
    const int num_rm = sizeof(SseRmVals) / sizeof (SseRm);
    Uint32 mxcsr_save = SseGetMxcsr();

    src1.r32 = (float)M_PI;
    src2.r64 = -M_E;

    for (int i = 0; i < num_rm; i++)
    {
        SseRm rm1 = SseRmVals[i];
        SseRm rm2;

        SseSetMxcsrRoundingMode(rm1);
        rm2 = SseGetMxcsrRoundingMode();
        
        if (rm2 != rm1)
        {
            printf("  SSE rounding mode change failed)\n");
            printf("  rm1: %d  rm2: %d\n", rm1, rm2);
        }
        else
        {
            printf("X86-SSE rounding mode = %s\n", SseRmStrings[rm2]);

            SseSfpConversion(&des1, &src1, CvtOp::Cvtss2si);
            printf("  cvtss2si: %12lf --> %6d\n", src1.r32, des1.i32);

            SseSfpConversion(&des2, &src2, CvtOp::Cvtsd2si);
            printf("  cvtsd2si: %12lf --> %6d\n", src2.r64, des2.i32);
        }
    }

    SseSetMxcsr(mxcsr_save);
}
int main(int argc, char* argv[])
{
    SseSfpConversions();
    return 0;
}
