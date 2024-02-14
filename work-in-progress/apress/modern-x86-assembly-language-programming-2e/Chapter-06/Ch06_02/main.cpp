//------------------------------------------------
//               Ch06_02.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#define _USE_MATH_DEFINES
#include <math.h>
#include <limits>
#include "XmmVal.h"

using namespace std;

extern "C" void AvxPackedCompareF32_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);
extern "C" void AvxPackedCompareF64_(const XmmVal& a, const XmmVal& b, XmmVal c[8]);

const char* c_CmpStr[8] =
{
    "EQ", "NE", "LT", "LE", "GT", "GE", "ORDERED", "UNORDERED"
};

void AvxPackedCompareF32(void)
{
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;
    alignas(16) XmmVal c[8];

    a.m_F32[0] = 2.0;         b.m_F32[0] = 1.0;
    a.m_F32[1] = 7.0;         b.m_F32[1] = 12.0;
    a.m_F32[2] = -6.0;        b.m_F32[2] = -6.0;
    a.m_F32[3] = 3.0;         b.m_F32[3] = 8.0;

    for (int i = 0; i < 2; i++)
    {
        if (i == 1)
            a.m_F32[0] = numeric_limits<float>::quiet_NaN();

        AvxPackedCompareF32_(a, b, c);

        cout << "\nResults for AvxPackedCompareF32 (iteration = " << i << ")\n";
        cout << setw(11) << 'a' << ':' << a.ToStringF32() << '\n';
        cout << setw(11) << 'b' << ':' << b.ToStringF32() << '\n';
        cout << '\n';

        for (int j = 0; j < 8; j++)
            cout << setw(11) << c_CmpStr[j] << ':' << c[j].ToStringX32() << '\n';
    }
}

void AvxPackedCompareF64(void)
{
    alignas(16) XmmVal a;
    alignas(16) XmmVal b;
    alignas(16) XmmVal c[8];

    a.m_F64[0] = 2.0;       b.m_F64[0] = M_E;
    a.m_F64[1] = M_PI;      b.m_F64[1] = -M_1_PI;

    for (int i = 0; i < 2; i++)
    {
        if (i == 1)
        {
            a.m_F64[0] = numeric_limits<double>::quiet_NaN();
            b.m_F64[1] = a.m_F64[1];
        }

        AvxPackedCompareF64_(a, b, c);

        cout << "\nResults for AvxPackedCompareF64 (iteration = " << i << ")\n";
        cout << setw(11) << 'a' << ':' << a.ToStringF64() << '\n';
        cout << setw(11) << 'b' << ':' << b.ToStringF64() << '\n';
        cout << '\n';

        for (int j = 0; j < 8; j++)
            cout << setw(11) << c_CmpStr[j] << ':' << c[j].ToStringX64() << '\n';
    }
}

int main()
{
    AvxPackedCompareF32();
    AvxPackedCompareF64();
    return 0;
}
