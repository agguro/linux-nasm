//------------------------------------------------
//               Ch03_01.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>

using namespace std;

extern "C" int CalcArraySum_(const int* x, int n);

int CalcArraySumCpp(const int* x, int n)
{
    int sum = 0;

    for (int i = 0; i < n; i++)
        sum += *x++;

    return sum;
}

int main()
{
    int x[] {3, 17, -13, 25, -2, 9, -6, 12, 88, -19};
    int n = sizeof(x) / sizeof(int);

    cout << "Elements of array x" << '\n';

    for (int i = 0; i < n; i++)
        cout << "x[" << i << "] = " << x[i] << '\n';
    cout << '\n';

    int sum1 = CalcArraySumCpp(x, n);
    int sum2 = CalcArraySum_(x, n);

    cout << "sum1 = " << sum1 << '\n';
    cout << "sum2 = " << sum2 << '\n';

    return 0;
}
