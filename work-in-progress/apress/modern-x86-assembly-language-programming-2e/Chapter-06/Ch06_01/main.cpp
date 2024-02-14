//------------------------------------------------
//               Ch06_01.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#define _USE_MATH_DEFINES
#include <math.h>
#include "XmmVal.h"

using namespace std;

extern "C" void AvxPackedMathF32_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);
extern "C" void AvxPackedMathF64_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);

void AvxPackedMathF32(void)
{
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;
    alignas(16) XmmVal c[8];

    a.m_F32[0] = 36.0f;                 b.m_F32[0] = -(float)(1.0 / 9.0);
    a.m_F32[1] = (float)(1.0 / 32.0);   b.m_F32[1] = 64.0f;
    a.m_F32[2] = 2.0f;                  b.m_F32[2] = -0.0625f;
    a.m_F32[3] = 42.0f;                 b.m_F32[3] = 8.666667f;

    AvxPackedMathF32_(a, b, c);

    cout << ("\nResults for AvxPackedMathF32\n");
    cout << "a:       " << a.ToStringF32() << '\n';
    cout << "b:       " << b.ToStringF32() << '\n';
    cout << '\n';
    cout << "addps:   " << c[0].ToStringF32() << '\n';
    cout << "subps:   " << c[1].ToStringF32() << '\n';
    cout << "mulps:   " << c[2].ToStringF32() << '\n';
    cout << "divps:   " << c[3].ToStringF32() << '\n';
    cout << "absps b: " << c[4].ToStringF32() << '\n';
    cout << "sqrtps a:" << c[5].ToStringF32() << '\n';
    cout << "minps:   " << c[6].ToStringF32() << '\n';
    cout << "maxps:   " << c[7].ToStringF32() << '\n';
}

void AvxPackedMathF64(void)
{
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;
    alignas(16) XmmVal c[8];

    a.m_F64[0] = 2.0;       b.m_F64[0] = M_E;
    a.m_F64[1] = M_PI;      b.m_F64[1] = -M_1_PI;

    AvxPackedMathF64_(a, b, c);

    cout << ("\nResults for AvxPackedMathF64\n");
    cout << "a:       " << a.ToStringF64() << '\n';
    cout << "b:       " << b.ToStringF64() << '\n';
    cout << '\n';
    cout << "addpd:   " << c[0].ToStringF64() << '\n';
    cout << "subpd:   " << c[1].ToStringF64() << '\n';
    cout << "mulpd:   " << c[2].ToStringF64() << '\n';
    cout << "divpd:   " << c[3].ToStringF64() << '\n';
    cout << "abspd b: " << c[4].ToStringF64() << '\n';
    cout << "sqrtpd a:" << c[5].ToStringF64() << '\n';
    cout << "minpd:   " << c[6].ToStringF64() << '\n';
    cout << "maxpd:   " << c[7].ToStringF64() << '\n';
}

int main()
{
    AvxPackedMathF32();
    AvxPackedMathF64();
    return 0;
}
