//------------------------------------------------
//               Ch05_10.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <cstdint>

using namespace std;

extern "C" bool Cc2_(const int64_t* a, const int64_t* b, int32_t n, int64_t * sum_a, int64_t* sum_b, int64_t* prod_a, int64_t* prod_b);

int main()
{
    const int n = 6;
    int64_t a[n] = { 2, -2, -6, 7, 12, 5 };
    int64_t b[n] = { 3, 5, -7, 8, 4, 9 };
    int64_t sum_a, sum_b;
    int64_t prod_a, prod_b;

    bool rc = Cc2_(a, b, n, &sum_a, &sum_b, &prod_a, &prod_b);

    cout << "Results for Cc2\n\n";

    if (rc)
    {
        const int w = 6;
        const char nl = '\n';
        const char* ws = "   ";

        for (int i = 0; i < n; i++)
        {
            cout << "i: " << setw(w) << i << ws;
            cout << "a: " << setw(w) << a[i] << ws;
            cout << "b: " << setw(w) << b[i] << nl;
        }

        cout <<  nl;
        cout << "sum_a =  " << setw(w) << sum_a << ws;
        cout << "sum_b =  " << setw(w) << sum_b << nl;
        cout << "prod_a = " << setw(w) << prod_a << ws;
        cout << "prod_b = " << setw(w) << prod_b << nl;
    }
    else
        cout << "Invalid return code\n";

    return 0;
}
