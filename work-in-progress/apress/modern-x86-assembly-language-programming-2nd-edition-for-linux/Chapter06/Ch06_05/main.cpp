//------------------------------------------------
//               Ch06_05.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include <random>
#include <limits>
#include "AlignedMem.h"

using namespace std;

extern "C" float g_MinValInit = numeric_limits<float>::max();
extern "C" float g_MaxValInit = -numeric_limits<float>::max();

extern "C" bool CalcArrayMinMaxF32_(float* min_val, float* max_val, const float* x, size_t n);

void Init(float* x, size_t n, unsigned int seed)
{
    uniform_int_distribution<> ui_dist {1, 10000};
    default_random_engine rng {seed};

    for (size_t i = 0; i < n; i++)
        x[i] = (float)ui_dist(rng);
}

bool CalcArrayMinMaxF32Cpp(float* min_val, float* max_val, const float* x, size_t n)
{
    // Make sure x is properly aligned
    if (!AlignedMem::IsAligned(x, 16))
        return false;

    // Find array minimum and maximum values
    float min_val_temp = g_MinValInit;
    float max_val_temp = g_MaxValInit;

    if (n > 0)
    {
        for (size_t i = 0; i < n; i++)
        {
            if (x[i] < min_val_temp)
                min_val_temp = x[i];

            if (x[i] > max_val_temp)
                max_val_temp = x[i];
        }
    }

    *min_val = min_val_temp;
    *max_val = max_val_temp;
    return true;
}

int main()
{
    const size_t n = 31;
    alignas(16) float x[n];

    Init(x, n, 73);

    float min_val1, max_val1;
    float min_val2, max_val2;

    CalcArrayMinMaxF32Cpp(&min_val1, &max_val1, x, n);
    CalcArrayMinMaxF32_(&min_val2, &max_val2, x, n);

    cout << fixed << setprecision(1);
    cout << "-------------- Array x --------------\n";

    for (size_t i = 0; i < n; i++)
    {
        cout << "x[" << setw(2) << i << "]: " << setw(9) << x[i];

        if (i & 1)
            cout << '\n';
        else
            cout << "    ";
    }

    cout << '\n';

    cout << "\nResults for CalcArrayMinMaxF32Cpp\n";
    cout << "  min_val = " << setw(9) << min_val1 << ", ";
    cout << "  max_val = " << setw(9) << max_val1 << '\n';

    cout << "\nResults for CalcArrayMinMaxF32_\n";
    cout << "  min_val = " << setw(9) << min_val2 << ", ";
    cout << "  max_val = " << setw(9) << max_val2 << '\n';

    return 0;
}
