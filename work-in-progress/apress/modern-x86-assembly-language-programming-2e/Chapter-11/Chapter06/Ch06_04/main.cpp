//------------------------------------------------
//               Ch06_04.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include <random>

using namespace std;

extern "C" bool AvxCalcSqrts_(float* y, const float* x, size_t n);

void Init(float* x, size_t n, unsigned int seed)
{
    uniform_int_distribution<> ui_dist {1, 2000};
    default_random_engine rng {seed};

    for (size_t i = 0; i < n; i++)
        x[i] = (float)ui_dist(rng);
}

bool AvxCalcSqrtsCpp(float* y, const float* x, size_t n)
{
    const size_t alignment = 16;

    if (n == 0)
        return false;

    if (((uintptr_t)x % alignment) != 0)
        return false;

    if (((uintptr_t)y % alignment) != 0)
        return false;

    for (size_t i = 0; i < n; i++)
        y[i] = sqrt(x[i]);

    return true;
}

int main()
{
    const size_t n = 19;
    alignas(16) float x[n];
    alignas(16) float y1[n];
    alignas(16) float y2[n];

    Init(x, n, 53);

    bool rc1 = AvxCalcSqrtsCpp(y1, x, n);
    bool rc2 = AvxCalcSqrts_(y2, x, n);

    cout << fixed << setprecision(4);
    cout << "\nResults for AvxCalcSqrts\n";

    if (!rc1 || !rc2)
        cout << "Invalid return code\n";
    else
    {
        const char* sp = "   ";

        for (size_t i = 0; i < n; i++)
        {
            cout << "i:  " << setw(2) << i << sp;
            cout << "x:  " << setw(9) << x[i] << sp;
            cout << "y1: " << setw(9) << y1[i] << sp;
            cout << "y2: " << setw(9) << y2[i] << '\n';
        }
    }
}
