//------------------------------------------------
//               Ch06_06.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include <cstddef>
#include "AlignedMem.h"

using namespace std;

extern "C" double LsEpsilon = 1.0e-12;
extern "C" bool AvxCalcLeastSquares_(const double* x, const double* y, int n, double* m, double* b);

bool AvxCalcLeastSquaresCpp(const double* x, const double* y, int n, double* m, double* b)
{
    if (n < 2)
        return false;
    if (!AlignedMem::IsAligned(x, 16) || !AlignedMem::IsAligned(y, 16))
        return false;

    double sum_x = 0, sum_y = 0.0, sum_xx = 0, sum_xy = 0.0;

    for (int i = 0; i < n; i++)
    {
        sum_x += x[i];
        sum_xx += x[i] * x[i];
        sum_xy += x[i] * y[i];
        sum_y += y[i];
    }

    double denom = n * sum_xx - sum_x * sum_x;

    if (fabs(denom) >= LsEpsilon)
    {
        *m = (n * sum_xy - sum_x * sum_y) / denom;
        *b = (sum_xx * sum_y - sum_x * sum_xy) / denom;
        return true;
    }
    else
    {
        *m = *b = 0.0;
        return false;
    }
}

int main()
{
    const int n = 11;
    alignas(16) double x[n] = {10, 13, 17, 19, 23, 7, 35, 51, 89, 92, 99};
    alignas(16) double y[n] = {1.2, 1.1, 1.8, 2.2, 1.9, 0.5, 3.1, 5.5, 8.4, 9.7, 10.4};
    double m1 = 0, m2 = 0;
    double b1 = 0, b2 = 0;

    bool rc1 = AvxCalcLeastSquaresCpp(x, y, n, &m1, &b1);
    bool rc2 = AvxCalcLeastSquares_(x, y, n, &m2, &b2);

    cout << fixed << setprecision(8);

    cout << "\nResults from AvxCalcLeastSquaresCpp\n";
    cout << "  rc:         " << setw(12) << boolalpha << rc1 << '\n';
    cout << "  slope:      " << setw(12) << m1 << '\n';
    cout << "  intercept:: " << setw(12) << b1 << '\n';

    cout << "\nResults from AvxCalcLeastSquares_\n";
    cout << "  rc:         " << setw(12) << boolalpha << rc2 << '\n';
    cout << "  slope:      " << setw(12) << m2 << '\n';
    cout << "  intercept:: " << setw(12) << b2 << '\n';

    return 0;
}
