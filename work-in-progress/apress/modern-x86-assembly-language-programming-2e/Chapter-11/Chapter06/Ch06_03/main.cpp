//------------------------------------------------
//               Ch06_03.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#define _USE_MATH_DEFINES
#include <math.h>
#include "XmmVal.h"

using namespace std;

// The order of values in the following enum must match the jump table
// that's defined in Ch06_03_.asm.
enum CvtOp : unsigned int
{
    I32_F32, F32_I32, I32_F64, F64_I32, F32_F64, F64_F32,
};

extern "C" bool AvxPackedConvertFP_(const XmmVal& a, XmmVal& b, CvtOp cvt_op);

void AvxPackedConvertF32(void)
{
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;

    a.m_I32[0] = 10;
    a.m_I32[1] = -500;
    a.m_I32[2] = 600;
    a.m_I32[3] = -1024;
    AvxPackedConvertFP_(a, b, CvtOp::I32_F32);
    cout << "\nResults for CvtOp::I32_F32\n";
    cout << "a: " << a.ToStringI32() << '\n';
    cout << "b: " << b.ToStringF32() << '\n';

    a.m_F32[0] = 1.0f / 3.0f;
    a.m_F32[1] = 2.0f / 3.0f;
    a.m_F32[2] = -a.m_F32[0] * 2.0f;
    a.m_F32[3] = -a.m_F32[1] * 2.0f;
    AvxPackedConvertFP_(a, b, CvtOp::F32_I32);
    cout << "\nResults for CvtOp::F32_I32\n";
    cout << "a: " << a.ToStringF32() << '\n';
    cout << "b: " << b.ToStringI32() << '\n';

    // F32_F64 converts the two low-order SPFP values of 'a'
    a.m_F32[0] = 1.0f / 7.0f;
    a.m_F32[1] = 2.0f / 9.0f;
    a.m_F32[2] = 0;
    a.m_F32[3] = 0;
    AvxPackedConvertFP_(a, b, CvtOp::F32_F64);
    cout << "\nResults for CvtOp::F32_F64\n";
    cout << "a: " << a.ToStringF32() << '\n';
    cout << "b: " << b.ToStringF64() << '\n';
}

void AvxPackedConvertF64(void)
{
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;

    // I32_F64 converts the two low-order doubleword integers of 'a'
    a.m_I32[0] = 10;
    a.m_I32[1] = -20;
    a.m_I32[2] = 0;
    a.m_I32[3] = 0;
    AvxPackedConvertFP_(a, b, CvtOp::I32_F64);
    cout << "\nResults for CvtOp::I32_F64\n";
    cout << "a: " << a.ToStringI32() << '\n';
    cout << "b: " << b.ToStringF64() << '\n';

    // F64_I32 sets the two high-order doublewords of 'b' to zero
    a.m_F64[0] = M_PI;
    a.m_F64[1] = M_E;
    AvxPackedConvertFP_(a, b, CvtOp::F64_I32);
    cout << "\nResults for CvtOp::F64_I32\n";
    cout << "a: " << a.ToStringF64() << '\n';
    cout << "b: " << b.ToStringI32() << '\n';

    // F64_F32 sets the two high-order SPFP values of 'b' to zero
    a.m_F64[0] = M_SQRT2;
    a.m_F64[1] = M_SQRT1_2;
    AvxPackedConvertFP_(a, b, CvtOp::F64_F32);
    cout << "\nResults for CvtOp::F64_F32\n";
    cout << "a: " << a.ToStringF64() << '\n';
    cout << "b: " << b.ToStringF32() << '\n';
}

int main()
{
    AvxPackedConvertF32();
    AvxPackedConvertF64();
    return 0;
}
