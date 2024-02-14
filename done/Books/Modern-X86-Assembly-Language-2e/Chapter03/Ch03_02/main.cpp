//------------------------------------------------
//               Ch03_02.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <cassert>

using namespace std;

extern "C" long long CalcArrayValues_(long long* y, const int* x, int a, short b, int n);

long long CalcArrayValuesCpp(long long* y, const int* x, int a, short b,  int n)
{
    long long sum = 0;

    for (int i = 0; i < n; i++)
    {
        y[i] = (long long)x[i] * a + b;
        sum += y[i];
    }

    return sum;
}

int main()
{
    const int a = -6;
    const short b = -13;
    const int x[] {26, 12, -53, 19, 14, 21, 31, -4, 12, -9, 41, 7};
    const int n = sizeof(x) / sizeof(int);

    long long y1[n];
    long long y2[n];

    long long sum_y1 = CalcArrayValuesCpp(y1, x, a, b, n);
    long long sum_y2 = CalcArrayValues_(y2, x, a, b, n);

    cout << "a = " << a << '\n';
    cout << "b = " << b << '\n';
    cout << "n = " << n << "\n\n";

    for (int i = 0; i < n; i++)
    {
        cout << "i: " << setw(2) << i << "  ";
        cout << "x: " << setw(6) << x[i] << "  ";
        cout << "y1: " << setw(6) << y1[i] << "  ";
        cout << "y2: " << setw(6) << y2[i] << '\n';
    }

    cout << '\n';
    cout << "sum_y1 = " << sum_y1 << '\n';
    cout << "sum_y2 = " << sum_y2 << '\n';

    return 0;
}
