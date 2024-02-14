//------------------------------------------------
//               Ch05_06.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <cstdint>
#include <string>
#define _USE_MATH_DEFINES
#include <math.h>
#include <cfloat>   //for DBL_EPSILON

using namespace std;

// Simple union for data exchange
union Uval
{
    int32_t m_I32;
    int32_t m_I64;
    float m_F32;
    double m_F64;
};

// The order of values below must match the jump table
// that's defined in the .asm file.
enum CvtOp : unsigned int
{
    I32_F32,       // int32_t to float
    F32_I32,       // float to int32_t
    I32_F64,       // int32_t to double
    F64_I32,       // double to int32_t
    I64_F32,       // int64_t to float
    F32_I64,       // float to int64_t
    I64_F64,       // int64_t to double
    F64_I64,       // double to int64_t
    F32_F64,       // float to double
    F64_F32,       // double to float
};

// Enumerated type for rounding mode
enum RoundingMode : unsigned int
{
    Nearest, Down, Up, Truncate
};

const string c_RoundingModeStrings[] = {"Nearest", "Down", "Up", "Truncate"};
const RoundingMode c_RoundingModeVals[] = {RoundingMode::Nearest, RoundingMode::Down, RoundingMode::Up, RoundingMode::Truncate};
const size_t c_NumRoundingModes = sizeof(c_RoundingModeVals) / sizeof (RoundingMode);

extern "C" RoundingMode GetMxcsrRoundingMode_(void);
extern "C" void SetMxcsrRoundingMode_(RoundingMode rm);
extern "C" bool ConvertScalar_(Uval* a, Uval* b, CvtOp cvt_op);

int main()
{
    Uval src1, src2, src3, src4, src5;

    src1.m_F32 = (float)M_PI;
    src2.m_F32 = (float)-M_E;
    src3.m_F64 = M_SQRT2;
    src4.m_F64 = M_SQRT1_2;
    src5.m_F64 = 1.0 + DBL_EPSILON;

    for (size_t i = 0; i < c_NumRoundingModes; i++)
    {
        Uval des1, des2, des3, des4, des5;
        RoundingMode rm_save = GetMxcsrRoundingMode_();
        RoundingMode rm_test = c_RoundingModeVals[i];

        SetMxcsrRoundingMode_(rm_test);

        ConvertScalar_(&des1, &src1, CvtOp::F32_I32);
        ConvertScalar_(&des2, &src2, CvtOp::F32_I64);
        ConvertScalar_(&des3, &src3, CvtOp::F64_I32);
        ConvertScalar_(&des4, &src4, CvtOp::F64_I64);
        ConvertScalar_(&des5, &src5, CvtOp::F64_F32);

        SetMxcsrRoundingMode_(rm_save);

        cout << fixed;
        cout << "\nRounding mode = " << c_RoundingModeStrings[rm_test] << '\n';

        cout << "  F32_I32: " << setprecision(8);
        cout << src1.m_F32 << " --> " << des1.m_I32 << '\n';

        cout << "  F32_I64: " << setprecision(8);
        cout << src2.m_F32 << " --> " << des2.m_I64 << '\n';

        cout << "  F64_I32: " << setprecision(8);
        cout << src3.m_F64 << " --> " << des3.m_I32 << '\n';

        cout << "  F64_I64: " << setprecision(8);
        cout << src4.m_F64 << " --> " << des4.m_I64 << '\n';

        cout << "  F64_F32: ";
        cout << setprecision(16) << src5.m_F64 << " --> ";
        cout << setprecision(8) << des5.m_F32 << '\n';
    }

    return 0;
}
